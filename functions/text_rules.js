'use strict';

// Szabályalapú szövegszűrő a hirdetésekhez. Szándékosan konzervatív:
//  - HARD: egyértelműen tiltott tartalom -> automatikus elutasítás
//  - REVIEW: gyanús minta -> a hirdetés "függő" marad, az admin dönt
// A listákat nyugodtan bővítheted; a mintákat ékezet- és kisbetű-függetlenül illesztjük.

function normalize(s) {
  return String(s || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '') // ékezetek (görög is) törlése
    .replace(/[@4]/g, (c) => (c === '@' ? 'a' : 'a'))
    .replace(/0/g, 'o')
    .replace(/[^a-z0-9Ͱ-ϿЀ-ӿ\s+./:-]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

const HARD = [
  { id: 'drugs', label: 'Drog értékesítése', re: /\b(cocaine|kokain|heroin|heroine|mdma|ecstasy|amphetamine|metamfetamin|meth for sale|marihuana elado|weed for sale|cannabis for sale|drogok elado|buy drugs)\b/ },
  { id: 'weapons', label: 'Fegyver értékesítése', re: /\b(gun for sale|guns for sale|firearms? for sale|fegyver elado|loszer elado|ammunition for sale|buy a gun|pisztoly elado)\b/ },
  { id: 'sexual', label: 'Szexuális szolgáltatás', re: /\b(escort|erotic massage|erotikus maszazs|sex service|szexualis szolgaltatas|happy ending|call ?girls?|prostitu\w*|szexpartner)\b/ },
  { id: 'documents', label: 'Hamis okmány', re: /\b(fake (passport|id|documents?|diploma)|hamis (utlevel|igazolvany|okmany)|forged documents?)\b/ },
  { id: 'hate', label: 'Gyűlöletkeltés / erőszak', re: /\b(kill (all|the) |death to |halal a |white power|nazi propaganda)\b/ },
];

const REVIEW = [
  { id: 'prepay', label: 'Előleg / előre fizetés kérése megtekintés előtt', re: /\b(western union|moneygram|wire transfer (first|before)|advance payment|pay (the )?deposit before|deposit before (viewing|visit)|eloleg (atutal|kuld)\w*|atutalas megtekintes elott|before you (visit|view)|prepayment)\b/ },
  { id: 'crypto', label: 'Kriptofizetés', re: /\b(bitcoin|btc|usdt|crypto(currency)? only|kripto)\b/ },
  { id: 'offplatform', label: 'Platformon kívüli kapcsolatfelvétel', re: /\b(telegram|signal app|contact me on (whatsapp|telegram)|write me on gmail)\b/ },
  { id: 'urgent', label: 'Sürgető / csalásra utaló szöveg', re: /\b(i am (abroad|overseas|a missionary)|keys? (will be )?(sent|shipped|mailed)|send (the )?keys by (post|courier)|owner is abroad)\b/ },
];

const CONTACT_RE = {
  email: /[a-z0-9._%+-]+\s?(@|\(at\)|\[at\])\s?[a-z0-9.-]+\.[a-z]{2,}/i,
  phone: /(\+|00)?\d[\d\s().-]{8,}\d/,
  url: /(https?:\/\/|www\.)\S+/i,
};

/**
 * @param {{title?:string, description?:string, address?:string, category?:string, price?:number, listingType?:string, priceUnit?:string}} d
 * @returns {{hard: string[], review: string[]}}
 */
function checkText(d) {
  const hard = [];
  const review = [];

  const rawJoined = [d.title, d.description, d.address, d.category].filter(Boolean).join(' \n ');
  const text = normalize(rawJoined);

  for (const r of HARD) if (r.re.test(text)) hard.push(r.label);
  for (const r of REVIEW) if (r.re.test(text)) review.push(r.label);

  // Elérhetőség a leírásban: a telefonszámot külön mező kezeli, a leírásban kerüljük (chat megkerülése)
  const desc = String(d.description || '') + ' ' + String(d.title || '');
  if (CONTACT_RE.email.test(desc) || CONTACT_RE.url.test(desc)) review.push('E-mail cím vagy link a leírásban');
  if (CONTACT_RE.phone.test(desc)) review.push('Telefonszám a leírásban');

  // Csupa nagybetűs cím
  const title = String(d.title || '');
  if (title.length > 12 && title === title.toUpperCase() && /[A-Z]/.test(title)) review.push('Csupa nagybetűs cím');

  // Ár-ésszerűség
  const price = Number(d.price);
  if (Number.isFinite(price)) {
    if (d.listingType === 'rent' && d.priceUnit === 'night' && (price < 5 || price > 5000)) review.push('Szokatlan éjszakai ár');
    if (d.listingType === 'rent' && d.priceUnit === 'month' && (price < 50 || price > 50000)) review.push('Szokatlan havi bérleti díj');
    if (d.listingType === 'sale' && (price < 1000 || price > 50000000)) review.push('Szokatlan eladási ár');
    if (!d.listingType && price === 0) review.push('Nulla ár');
  }

  return { hard: [...new Set(hard)], review: [...new Set(review)] };
}

module.exports = { checkText, normalize };
