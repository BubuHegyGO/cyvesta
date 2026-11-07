'use strict';
// Gyors helyi önteszt (nem kell hozzá Firebase): node test_rules.js
const assert = require('assert');
const { checkText } = require('./text_rules');
const { nameSimilarity, normalizeVat, normalizeHe } = require('./vat');

const clean = checkText({ title: 'Sea view apartment in Paphos', description: 'Bright 2 bedroom apartment, 5 min walk to the beach.', address: 'Poseidonos Ave 12, Paphos', category: 'Ingatlan', price: 90, listingType: 'rent', priceUnit: 'night' });
assert.deepStrictEqual(clean, { hard: [], review: [] });

assert.ok(checkText({ title: 'x', description: 'Cocaine for sale', price: 1 }).hard.length > 0);
assert.ok(checkText({ title: 'Flat', description: 'Send deposit before viewing via Western Union', price: 100, listingType: 'rent', priceUnit: 'night' }).review.length > 0);
assert.ok(checkText({ title: 'Flat', description: 'Write to me: john@example.com', price: 100, listingType: 'rent', priceUnit: 'night' }).review.length > 0);
assert.ok(checkText({ title: 'Flat', description: 'ok', price: 1, listingType: 'rent', priceUnit: 'night' }).review.length > 0);

assert.strictEqual(normalizeVat('cy 10259033p'), '10259033P');
assert.strictEqual(normalizeVat('123'), null);
assert.strictEqual(normalizeHe('he 123456'), 'HE 123456');
assert.strictEqual(normalizeHe('abc'), null);
assert.ok(nameSimilarity('Sunny Homes Ltd', 'SUNNY HOMES LIMITED') >= 0.99);
assert.ok(nameSimilarity('Sunny Homes Ltd', 'Blue Waves Properties Ltd') < 0.6);
console.log('Minden önteszt rendben.');
