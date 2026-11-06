import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'auth_state.dart';

class ListingDuplicateService {
  /// Egységes alak az összehasonlításhoz: kisbetű, felesleges szóközök nélkül.
  static String normalizeAddress(String address) {
    return address.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Ellenőrzi, hogy a megadott cím vagy képek alapján létezik-e már jóváhagyott hirdetés más partnernél.
  ///
  /// Fontos: ez csak kliensoldali segédellenőrzés. A kliens a Security Rules miatt csak a jóváhagyott
  /// hirdetéseket látja, a függőben lévőket nem, ezért a teljes védelmet a moderáció (és később egy
  /// szerveroldali Cloud Function) adja.
  static Future<Map<String, dynamic>> checkDuplicate({
    required String address,
    required List<String> imageUrls,
  }) async {
    final normalized = normalizeAddress(address);
    if (normalized.isEmpty) {
      return {'isDuplicate': false};
    }

    final uid = AuthState.currentUserId;
    final listings = FirebaseFirestore.instance.collection('listings');

    try {
      // 1. Cím egyezés (indexelt lekérdezés, nem a teljes gyűjteményt töltjük le)
      final byAddress = await listings
          .where('status', isEqualTo: 'approved')
          .where('addressNormalized', isEqualTo: normalized)
          .limit(10)
          .get();

      for (final doc in byAddress.docs) {
        if (doc.data()['partnerId'] != uid) {
          return {
            'isDuplicate': true,
            'reason': 'Ezzel a pontos címmel ($address) már létezik hirdetés egy másik partner nevén! ⚠️',
          };
        }
      }

      // 2. Kép-egyezés (ha pontosan ugyanazokat a fotókat töltik fel)
      if (imageUrls.isNotEmpty) {
        final byImage = await listings
            .where('status', isEqualTo: 'approved')
            .where('imageUrls', arrayContainsAny: imageUrls.take(30).toList())
            .limit(10)
            .get();

        for (final doc in byImage.docs) {
          if (doc.data()['partnerId'] != uid) {
            return {
              'isDuplicate': true,
              'reason': 'A feltöltött képek egyike már szerepel egy másik hirdetésben! Tilos más fotóit felhasználni. 🚫',
            };
          }
        }
      }

      return {'isDuplicate': false};
    } catch (e) {
      debugPrint('Hiba a duplikáció ellenőrzésekor: $e');
      return {'isDuplicate': false}; // Hiba esetén engedjük, a moderáció úgyis átnézi
    }
  }
}
