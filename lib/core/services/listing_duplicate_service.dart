import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'auth_state.dart';

class ListingDuplicateService {
  /// Ellenőrzi, hogy a megadott cím vagy képek alapján létezik-e már aktív hirdetés más partnernél.
  static Future> checkDuplicate({
    required String address,
    required List<String> imageUrls,
  }) async {
    try {
      final trimmedAddress = address.trim().toLowerCase();
      if (trimmedAddress.isEmpty) {
        return {'isDuplicate': false};
      }

      // Lekérdezzük a Firestore-ból a meglévő hirdetéseket
      final querySnapshot = await FirebaseFirestore.instance
          .collection('listings')
          .get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final existingAddress = (data['address'] ?? '').toString().trim().toLowerCase();
        final existingPartnerId = data['partnerId'] ?? '';
        final List<dynamic> existingImages = data['imageUrls'] ?? [];

        // 1. Cím egyezés vizsgálata (ha nem a saját hirdetésünket szerkesztjük)
        if (existingAddress.isNotEmpty && existingAddress == trimmedAddress) {
          if (existingPartnerId != AuthState.currentUserId) {
            return {
              'isDuplicate': true,
              'reason': 'Ezzel a pontos címmel ($address) már létezik hirdetés egy másik partner nevén! ⚠️',
            };
          }
        }

        // 2. Kép-egyezés vizsgálata (ha pontosan ugyanazokat a fotókat töltik fel)
        for (var newImg in imageUrls) {
          if (existingImages.contains(newImg)) {
            if (existingPartnerId != AuthState.currentUserId) {
              return {
                'isDuplicate': true,
                'reason': 'A feltöltött képek egyike már szerepel egy másik hirdetésben! Tilos más fotóit felhasználni. 🚫',
              };
            }
          }
        }
      }

      return {'isDuplicate': false};
    } catch (e) {
      debugPrint('Hiba a duplikáció ellenőrzésekor: $e');
      return {'isDuplicate': false}; // Hiba esetén engedjük, de logoljuk
    }
  }
}