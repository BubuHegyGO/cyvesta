import 'package:flutter/material.dart';

class StepPhotos extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<String> uploadedPhotos;
  final ValueChanged<List<String>> onPhotosChanged;

  static const Color accent = Color(0xFF8BC541);

  const StepPhotos({
    super.key,
    required this.formKey,
    required this.uploadedPhotos,
    required this.onPhotosChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Képek feltöltése',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kép kiválasztva!'), backgroundColor: accent),
              );
            },
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent, width: 1.5),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_rounded, color: accent, size: 40),
                  SizedBox(height: 10),
                  Text('Kattints a fotók hozzáadásához', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}