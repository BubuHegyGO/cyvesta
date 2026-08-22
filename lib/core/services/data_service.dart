import 'package:flutter/material.dart';

class DataService {
  static final ValueNotifier<List<Map<String, dynamic>>> accommodations = ValueNotifier<List<Map<String, dynamic>>>([
    {
      'title': 'Luxury Paphos Villa',
      'location': 'Paphos, Cyprus',
      'price': '€150 / éj',
      'rating': '4.98',
      'imagePath': 'assets/images/szarvas.png',
      'category': 'accommodation',
      'status': 'approved',
    },
    {
      'title': 'Coral Bay Beach Apartment',
      'location': 'Coral Bay, Paphos',
      'price': '€95 / éj',
      'rating': '4.90',
      'imagePath': 'assets/images/szarvas.png',
      'category': 'accommodation',
      'status': 'approved',
    },
    {
      'title': 'Modern Sea View Villa For Sale',
      'location': 'Paphos, Chloraka',
      'price': '€320,000',
      'rating': '4.95',
      'imagePath': 'assets/images/szarvas.png',
      'category': 'sale',
      'status': 'approved',
    },
  ]);

  static final ValueNotifier<List<Map<String, dynamic>>> favoriteItems = ValueNotifier<List<Map<String, dynamic>>>([]);

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