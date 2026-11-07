'use strict';

const crypto = require('crypto');
const admin = require('firebase-admin');
const { setGlobalOptions } = require('firebase-functions/v2');
const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const logger = require('firebase-functions/logger');
const vision = require('@google-cloud/vision');

const { checkText } = require('./text_rules');
const { checkVies, nameSimilarity, normalizeVat, normalizeHe } = require('./vat');

admin.initializeApp();
const db = admin.firestore();
const visionClient = new vision.ImageAnnotatorClient();

// FONTOS: a Firestore adatbázisod helyéhez igazítsd (Firebase konzol -> Firestore -> Beállítások).
//   eur3 / europe-west1 ... -> 'europe-west1'   |   nam5 / us-central ... -> 'us-central1'
const REGION = 'europe-west1';
setGlobalOptions({ region: REGION, maxInstances: 5 });

// Ha true, a tiszta (nem gyanús) hirdetés automatikusan jóváhagyott lesz.
const AUTO_APPROVE_LISTINGS = true;
// Ha true, a VAT-ellenőrzésen átment + névegyezős partner automatikusan jóváhagyott lesz.
const AUTO_APPROVE_PARTNERS = true;
const NAME_MATCH_MIN = 0.6;

// ======================================================================
//  1) Hirdetés-moderáció
// ======================================================================

const LIKELIHOOD = { UNKNOWN: 0, VERY_UNLIKELY: 1, UNLIKELY: 2, POSSIBLE: 3, LIKELY: 4, VERY_LIKELY: 5 };
const lv = (v) => (typeof v === 'number' ? v : LIKELIHOOD[v] ?? 0);

function contentHash(d) {
  const basis = JSON.stringify([d.title, d.description, d.address, d.category, d.price, d.listingType, d.priceUnit, d.imageUrls || []]);
  return crypto.createHash('sha256').update(basis).digest('hex').slice(0, 32);
}

/** A Firebase Storage letöltési címből kiolvassa a bucketet és az objektum útvonalát. */
function parseStorageUrl(url) {
  try {
    const u = new URL(url);
    const m = /\/b\/([^/]+)\/o\/(.+)$/.exec(u.pathname);
    if (!m) return null;
    return { bucket: m[1], path: decodeURIComponent(m[2]) };
  } catch (_) {
    return null;
  }
}

async function checkImages(urls) {
  const hard = [];
  const review = [];
  const errors = [];

  for (let i = 0; i < urls.length; i++) {
    const n = i + 1;
    const parsed = parseStorageUrl(urls[i]);
    const path = parsed ? parsed.path : null;
    if (!parsed || !path.startsWith('listings/')) {
      errors.push(`${n}. kép: ismeretlen tárhely-cím`);
      continue;
    }
    try {
      const [buf] = await admin.storage().bucket(parsed.bucket).file(path).download();
      const [result] = await visionClient.safeSearchDetection({ image: { content: buf } });
      const s = result.safeSearchAnnotation;
      if (!s) {
        errors.push(`${n}. kép: nincs elemzési eredmény`);
        continue;
      }
      const adult = lv(s.adult);
      const violence = lv(s.violence);
      const racy = lv(s.racy);
      const medical = lv(s.medical);
      if (adult >= 5 || violence >= 5) hard.push(`${n}. kép: nem megfelelő tartalom (felnőtt/erőszak)`);
      else if (adult >= 4 || violence >= 4) review.push(`${n}. kép: valószínűleg nem megfelelő tartalom`);
      if (racy >= 5) review.push(`${n}. kép: kihívó tartalom`);
      if (medical >= 5) review.push(`${n}. kép: orvosi/sokkoló tartalom`);
    } catch (e) {
      logger.error('Kép ellenőrzési hiba', { path, error: e.message });
      errors.push(`${n}. kép: elemzési hiba`);
    }
  }
  return { hard, review, errors };
}

exports.moderateListing = onDocumentWritten(
  { document: 'listings/{listingId}', memory: '512MiB', timeoutSeconds: 180 },
  async (event) => {
    const after = event.data?.after?.data();
    if (!after) return; // törlés
    if (after.status !== 'pending') return; // csak a moderálásra váró hirdetéseket vizsgáljuk

    const hash = contentHash(after);
    if (after.moderation && after.moderation.contentHash === hash) {
      // Ugyanazt a tartalmat már megvizsgáltuk: ha csak a státusz került 'pending'-re (szerkesztés), állítsuk vissza az eredményt.
      const r = after.moderation.result;
      const target = r === 'approved' ? (AUTO_APPROVE_LISTINGS ? 'approved' : 'pending') : r === 'rejected' ? 'rejected' : 'pending';
      if (target !== after.status) await event.data.after.ref.update({ status: target });
      return;
    }

    const reasons = [];
    const text = checkText(after);
    const imgs = await checkImages(Array.isArray(after.imageUrls) ? after.imageUrls.slice(0, 10) : []);

    const hard = [...text.hard, ...imgs.hard];
    const review = [...text.review, ...imgs.review, ...imgs.errors];
    reasons.push(...hard, ...review);

    let result;
    let status = 'pending';
    if (hard.length) {
      result = 'rejected';
      status = 'rejected';
    } else if (review.length) {
      result = 'review';
    } else {
      result = 'approved';
      if (AUTO_APPROVE_LISTINGS) status = 'approved';
    }

    await event.data.after.ref.update({
      status,
      moderation: {
        result,
        reasons,
        contentHash: hash,
        checkedAt: admin.firestore.FieldValue.serverTimestamp(),
        auto: true,
      },
    });
    logger.info('Hirdetés moderálva', { id: event.params.listingId, result, reasons });
  }
);

// ======================================================================
//  2) Céges partner-ellenőrzés (VAT: VIES, HE: formai + admin)
// ======================================================================

exports.verifyPartner = onDocumentWritten({ document: 'partners/{uid}', timeoutSeconds: 60 }, async (event) => {
  const after = event.data?.after?.data();
  if (!after) return;
  if (after.status !== 'pending') return;

  const key = crypto.createHash('sha256').update(JSON.stringify([after.regType, after.regNumber, after.companyName])).digest('hex').slice(0, 24);
  if (after.verification && after.verification.key === key) return;

  const uid = event.params.uid;
  let state = 'pending'; // pending | approved | rejected
  let result = 'review';
  let reason = '';
  let extra = {};

  try {
    if (after.regType === 'VAT') {
      const vat = normalizeVat(after.regNumber);
      if (!vat) {
        state = 'rejected';
        result = 'invalid';
        reason = 'Érvénytelen adószám-formátum (várt: CY + 8 számjegy + 1 betű, pl. CY10259033P).';
      } else {
        const vies = await checkVies(vat);
        if (vies.state === 'invalid') {
          state = 'rejected';
          result = 'invalid';
          reason = 'Az adószám a VIES nyilvántartásban nem aktív vagy nem létezik.';
        } else if (vies.state === 'unavailable') {
          result = 'unavailable';
          reason = `A VIES most nem érhető el (${vies.reason}). Az admin kézzel ellenőrzi.`;
        } else {
          const sim = vies.name && vies.name !== '---' ? nameSimilarity(after.companyName, vies.name) : null;
          extra = { viesName: vies.name || '', viesAddress: vies.address || '', nameMatch: sim };
          if (sim === null) {
            result = 'review';
            reason = 'Az adószám érvényes, de a VIES nem ad vissza cégnevet – az admin ellenőrzi a névegyezést.';
          } else if (sim < NAME_MATCH_MIN) {
            result = 'review';
            reason = `Az adószám érvényes, de a cégnév nem egyezik (VIES: "${vies.name}"). Admin ellenőrzés szükséges.`;
          } else {
            // Egyedi-e a szám? Más, már jóváhagyott fiók ne használhassa ugyanazt.
            const dup = await db.collection('partners').where('regNumber', '==', after.regNumber).where('status', '==', 'approved').limit(1).get();
            const taken = dup.docs.some((d) => d.id !== uid);
            // Megerősített e-mail / közösségi bejelentkezés kell
            const user = await admin.auth().getUser(uid);
            const trusted = user.emailVerified || user.providerData.some((p) => p.providerId !== 'password');
            if (taken) {
              result = 'review';
              reason = 'Ezzel az adószámmal már van jóváhagyott partner. Admin ellenőrzés szükséges.';
            } else if (!trusted) {
              result = 'review';
              reason = 'Az adószám és a cégnév egyezik, de az e-mail cím még nincs megerősítve.';
            } else {
              result = 'verified';
              reason = 'Az adószám és a cégnév a VIES alapján egyezik.';
              if (AUTO_APPROVE_PARTNERS) state = 'approved';
            }
          }
        }
      }
    } else if (after.regType === 'HE') {
      const he = normalizeHe(after.regNumber);
      if (!he) {
        state = 'rejected';
        result = 'invalid';
        reason = 'Érvénytelen cégjegyzékszám-formátum (várt: HE + szám, pl. HE 123456).';
      } else {
        result = 'review';
        reason = `${he}: a ciprusi cégjegyzék (DRCOR) nem nyújt nyilvános API-t, ezért az admin ellenőrzi. Gyorsabb: adj meg adószámot (VAT) is.`;
      }
    } else {
      state = 'rejected';
      result = 'invalid';
      reason = 'Ismeretlen azonosító-típus.';
    }
  } catch (e) {
    logger.error('Partner ellenőrzési hiba', { uid, error: e.message });
    result = 'unavailable';
    reason = 'Az automatikus ellenőrzés hibára futott, az admin kézzel ellenőrzi.';
  }

  await event.data.after.ref.update({
    status: state,
    verification: {
      key,
      result,
      reason,
      ...extra,
      checkedAt: admin.firestore.FieldValue.serverTimestamp(),
      auto: true,
    },
  });
  logger.info('Partner ellenőrizve', { uid, state, result });
});
