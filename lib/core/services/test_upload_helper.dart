import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TestUploadHelper {
  static Future<void> uploadTestListing(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('listings').add({
        'title': 'Kings Palace Paphos',
        'address': 'Paphos, Cyprus',
        'region': 'paphos', // Fontos a térképes szűréshez!
        'price': '399 €',
        'rating': '4.95',
        'category': 'rent',
        'imageUrl': 'https://birlakcyprus.com/wp-content/uploads/2026/05/kings-palace.jpg', // Vagy bármilyen valós kép link
        'latitude': 34.7754,
        'longitude': 32.4245,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sikeres teszt feltöltés a Firestore-ba! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hiba történt a feltöltés során: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}