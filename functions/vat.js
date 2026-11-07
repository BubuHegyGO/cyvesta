'use strict';

// Cipruson a HE a cégjegyzékszám, a VAT a "CY" + 8 számjegy + 1 betű.
// A VIES (EU) csak a VAT számot tudja ellenőrizni. A cégjegyzék (DRCOR) nem ad nyilvános API-t,
// ezért a HE jelentkezés formai ellenőrzés után admin-jóváhagyásra kerül.

const STOP = new Set(['ltd', 'limited', 'co', 'company', 'inc', 'llc', 'plc', 'the', 'and', 'of', 'cy', 'cyprus', 'λτδ', 'ειδ', 'ε.π.ε', 'και']);

function tokens(name) {
  return String(name || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^a-z0-9Ͱ-ϿЀ-ӿ\s]/g, ' ')
    .split(/\s+/)
    .filter((t) => t.length > 1 && !STOP.has(t));
}

/** A két cégnév átfedése 0..1 (a rövidebb nevet vetjük a hosszabbhoz). */
function nameSimilarity(a, b) {
  const ta = tokens(a);
  const tb = tokens(b);
  if (!ta.length || !tb.length) return 0;
  const [short, long] = ta.length <= tb.length ? [ta, tb] : [tb, ta];
  const set = new Set(long);
  const hit = short.filter((t) => set.has(t)).length;
  return hit / short.length;
}

function normalizeVat(raw) {
  let v = String(raw || '').toUpperCase().replace(/[\s.-]/g, '');
  if (v.startsWith('CY')) v = v.slice(2);
  return /^[0-9]{8}[A-Z]$/.test(v) ? v : null;
}

function normalizeHe(raw) {
  const v = String(raw || '').toUpperCase().replace(/[\s.-]/g, '');
  const m = /^(?:HE)?([0-9]{1,7})$/.exec(v);
  return m ? `HE ${m[1]}` : null;
}

const UNAVAILABLE = new Set([
  'MS_UNAVAILABLE', 'TIMEOUT', 'SERVICE_UNAVAILABLE', 'MS_MAX_CONCURRENT_REQ',
  'GLOBAL_MAX_CONCURRENT_REQ', 'IP_BLOCKED', 'VAT_BLOCKED',
]);

/** VIES lekérdezés. Visszatér: {state:'valid'|'invalid'|'unavailable', name, address} */
async function checkVies(vat) {
  const url = `https://ec.europa.eu/taxation_customs/vies/rest-api/ms/CY/vat/${encodeURIComponent(vat)}`;
  try {
    const res = await fetch(url, { headers: { Accept: 'application/json' }, signal: AbortSignal.timeout(15000) });
    if (!res.ok) return { state: 'unavailable', reason: `VIES HTTP ${res.status}` };
    const data = await res.json();
    const err = data.userError || data.errorWrappers?.[0]?.error;
    if (err && UNAVAILABLE.has(String(err).toUpperCase())) return { state: 'unavailable', reason: `VIES: ${err}` };
    const valid = data.isValid ?? data.valid;
    if (valid === true) return { state: 'valid', name: data.name || '', address: data.address || '' };
    if (valid === false) return { state: 'invalid' };
    return { state: 'unavailable', reason: 'VIES: váratlan válasz' };
  } catch (e) {
    return { state: 'unavailable', reason: `VIES hiba: ${e.message}` };
  }
}

module.exports = { checkVies, nameSimilarity, normalizeVat, normalizeHe };
