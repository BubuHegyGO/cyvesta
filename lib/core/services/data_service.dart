import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DataService {
  /// A hirdetések listája. Az élő adatot a Firestore-ból töltjük (startListingsSync).
  static final ValueNotifier<List<Map<String, dynamic>>> accommodations =
  ValueNotifier<List<Map<String, dynamic>>>([]);

  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _listingsSub;

  /// Jóváhagyott hirdetések élő figyelése a Firestore-ból.
  static void startListingsSync() {
    _listingsSub?.cancel();
    _listingsSub = FirebaseFirestore.instance
        .collection('listings')
        .where('status', whereIn: ['approved', 'active'])
        .snapshots()
        .listen((snap) {
      final list = snap.docs.map(_fromDoc).toList();
      accommodations.value = list;
    }, onError: (e) {
      debugPrint('Listings sync error: $e');
    });
  }

  static Map<String, dynamic> _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final type = d['listingType']?.toString(); // 'rent' | 'sale' | null
    final unit = d['priceUnit']?.toString(); // 'night' | 'month' | null
    final price = (d['price'] is num) ? (d['price'] as num).toDouble() : 0.0;
    final priceText = _formatPrice(price, type, unit);
    final urls = (d['imageUrls'] is List) ? List<String>.from(d['imageUrls'].map((e) => e.toString())) : <String>[];

    return {
      'id': doc.id,
      'partnerId': d['partnerId']?.toString() ?? '',
      'contactPhone': d['contactPhone']?.toString() ?? '',
      'contactName': d['contactName']?.toString() ?? '',
      'icalUrl': d['icalUrl']?.toString() ?? '',
      'priceValue': price,
      'priceUnit': unit ?? '',
      'title': d['title']?.toString() ?? '',
      'location': d['address']?.toString() ?? '',
      'price': priceText,
      'rating': '',
      'imagePath': urls.isNotEmpty ? urls.first : 'assets/images/szarvas.png',
      'imageUrls': urls,
      'description': d['description']?.toString() ?? '',
      'details': d['details'] is Map ? Map<String, dynamic>.from(d['details']) : <String, dynamic>{},
      'latitude': d['latitude'],
      'longitude': d['longitude'],
      // Lista-szűréshez: 'sale' | 'rent' (típus nélküli hirdetés nem kerül az ingatlan-listákba)
      'category': type ?? 'other',
      'rawCategory': d['category']?.toString() ?? '',
      'status': d['status']?.toString() ?? 'approved',
    };
  }

  static String _formatPrice(double price, String? type, String? unit) {
    final n = price == price.roundToDouble() ? price.toInt().toString() : price.toStringAsFixed(2);
    final withSep = n.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
    if (type == 'rent') {
      return unit == 'month' ? '€$withSep / hó' : '€$withSep / éj';
    }
    return '€$withSep';
  }

  static final ValueNotifier<List<Map<String, dynamic>>> favoriteItems =
  ValueNotifier<List<Map<String, dynamic>>>([]);

  // Egyedi/egyéb kategóriák tárolása (pl. "Fagyizó")
  static final ValueNotifier<List<String>> customCategories =
  ValueNotifier<List<String>>([]);

  static void addCustomCategory(String categoryName) {
    final trimmed = categoryName.trim();
    if (trimmed.isNotEmpty) {
      final currentList = List<String>.from(customCategories.value);
      if (!currentList.contains(trimmed)) {
        currentList.add(trimmed);
        customCategories.value = currentList;
      }
    }
  }

  static bool isFavorite(Map<String, dynamic> item) {
    return favoriteItems.value.any((fav) => fav['title'] == item['title']);
  }

  static void toggleFavorite(Map<String, dynamic> item) {
    final currentList = List<Map<String, dynamic>>.from(favoriteItems.value);
    if (isFavorite(item)) {
      currentList.removeWhere((fav) => fav['title'] == item['title']);
    } else {
      currentList.add(item);
    }
    favoriteItems.value = currentList;
  }

  static void addAccommodation(Map<String, dynamic> newAccommodation) {
    final currentList = List<Map<String, dynamic>>.from(accommodations.value);
    currentList.add(newAccommodation);
    accommodations.value = currentList;
  }

  static void updateAccommodationStatus(dynamic itemOrTitle, String newStatus) {
    final currentList = List<Map<String, dynamic>>.from(accommodations.value);
    int index = -1;
    if (itemOrTitle is Map<String, dynamic>) {
      index = currentList.indexWhere((i) => i['title'] == itemOrTitle['title']);
    } else if (itemOrTitle is String) {
      index = currentList.indexWhere((i) => i['title'] == itemOrTitle || i['id'] == itemOrTitle);
    }
    if (index != -1) {
      currentList[index]['status'] = newStatus;
      accommodations.value = currentList;
    }
  }

  static void approveAccommodation(dynamic itemOrTitle) {
    updateAccommodationStatus(itemOrTitle, 'approved');
  }

  static void rejectAccommodation(dynamic itemOrTitle) {
    updateAccommodationStatus(itemOrTitle, 'rejected');
  }

  static void deleteListing(dynamic itemOrTitle) {
    final currentList = List<Map<String, dynamic>>.from(accommodations.value);
    if (itemOrTitle is Map<String, dynamic>) {
      currentList.removeWhere((i) => i['title'] == itemOrTitle['title']);
    } else if (itemOrTitle is String) {
      currentList.removeWhere((i) => i['title'] == itemOrTitle || i['id'] == itemOrTitle);
    }
    accommodations.value = currentList;
  }
}
