import 'package:flutter/material.dart';

class DataService {
  static final ValueNotifier<List<Map<String, dynamic>>> favoriteItems = ValueNotifier<List<Map<String, dynamic>>>([]);

  static final ValueNotifier<List<Map<String, dynamic>>> customListings = ValueNotifier<List<Map<String, dynamic>>>([]);

  static final ValueNotifier<List<Map<String, dynamic>>> accommodations = ValueNotifier<List<Map<String, dynamic>>>([
    {
      'id': 'acc_1',
      'title': 'VILLA CORAL BAY LUXURY 🏖️',
      'category': 'accommodation',
      'location': 'Coral Bay, Paphos',
      'price': '€240 / night',
      'rating': '4.98',
      'badge': 'PREMIUM VILLA',
      'status': 'approved',
      'imagePath': 'assets/images/szarvas.png',
      'phone': '+35799123456',
      'whatsapp': '+35799123456',
      'ical_url': '',
      'description': 'Exkluzív tengerparti villa privát medencével, panorámás kilátással és 4 tágas hálószobával.',
    },
    {
      'id': 'acc_2',
      'title': 'KYRENIA PANORAMA APARTMENT 🏰',
      'category': 'accommodation',
      'location': 'Kyrenia Old Town & Castle',
      'price': '€185,000',
      'rating': '4.95',
      'badge': 'FOR SALE',
      'status': 'approved',
      'imagePath': 'assets/images/szarvas.png',
      'phone': '+35799654321',
      'whatsapp': '+35799654321',
      'ical_url': '',
      'description': 'Befektetésre kiváló 2 hálószobás dizájn lakás hegyi és tengeri panorámával.',
    },
    {
      'id': 'acc_3',
      'title': 'CASTLE VIEW STEAKHOUSE 🥩',
      'category': 'gastronomy',
      'location': 'Kyrenia Castle Promenade',
      'price': '€32 / person',
      'rating': '4.97',
      'badge': 'PREMIUM STEAK',
      'status': 'approved',
      'imagePath': 'assets/images/etterem.png',
      'phone': '+35799112233',
      'whatsapp': '+35799112233',
      'ical_url': '',
      'description': 'Prémium tengerparti grillétterem és steakhouse lélegzetelállító kilátással.',
    },
    {
      'id': 'acc_4',
      'title': 'THE PALM ARTISAN BAKERY 🥐',
      'category': 'gastronomy',
      'location': 'Coral Bay Beachfront, Paphos',
      'price': '€4.50-tól',
      'rating': '4.95',
      'badge': 'COFFEE & BAKERY',
      'status': 'approved',
      'imagePath': 'assets/images/cukraszda.png',
      'phone': '+35799445566',
      'whatsapp': '+35799445566',
      'ical_url': '',
      'description': 'Kézműves pékáruk, frissen sült vajas croissant-ok és specialty kávék.',
    },
    {
      'id': 'acc_5',
      'title': 'KYRENIA HARBOUR BREEZE 🐟',
      'category': 'gastronomy',
      'location': 'Kyrenia Old Harbour',
      'price': '€24 / person',
      'rating': '4.93',
      'badge': 'SEAFOOD & MEZE',
      'status': 'approved',
      'imagePath': 'assets/images/csarda.png',
      'phone': '+35799778899',
      'whatsapp': '+35799778899',
      'ical_url': '',
      'description': 'Mediterrán kikötői taverna autentikus friss halételekkel és meze tálakkal.',
    },
  ]);

  static void addListing(Map<String, dynamic> item) {
    customListings.value = [item, ...customListings.value];
    accommodations.value = [item, ...accommodations.value];
  }

  static void approveAccommodation(String id) {
    final list = List<Map<String, dynamic>>.from(accommodations.value);
    final index = list.indexWhere((item) => item['id'] == id);
    if (index >= 0) {
      list[index]['status'] = 'approved';
      accommodations.value = list;
    }
  }

  static void rejectAccommodation(String id) {
    final list = List<Map<String, dynamic>>.from(accommodations.value);
    final index = list.indexWhere((item) => item['id'] == id);
    if (index >= 0) {
      list[index]['status'] = 'rejected';
      accommodations.value = list;
    }
  }

  static void deleteListing(String id) {
    final list = List<Map<String, dynamic>>.from(accommodations.value);
    list.removeWhere((item) => item['id'] == id);
    accommodations.value = list;

    final customList = List<Map<String, dynamic>>.from(customListings.value);
    customList.removeWhere((item) => item['id'] == id);
    customListings.value = customList;
  }

  static Future<bool> loginWithProvider(String provider) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }

  static bool isFavorite(Map<String, dynamic> item) {
    final itemId = item['id']?.toString() ?? item['title']?.toString() ?? '';
    return favoriteItems.value.any((fav) => (fav['id']?.toString() ?? fav['title']?.toString()) == itemId);
  }

  static void toggleFavorite(Map<String, dynamic> item) {
    final itemId = item['id']?.toString() ?? item['title']?.toString() ?? '';
    final list = List<Map<String, dynamic>>.from(favoriteItems.value);
    final existingIndex = list.indexWhere((fav) => (fav['id']?.toString() ?? fav['title']?.toString()) == itemId);

    if (existingIndex >= 0) {
      list.removeAt(existingIndex);
    } else {
      list.add(item);
    }

    favoriteItems.value = list;
  }
}