import 'package:flutter/material.dart';

class StepPricing extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController priceController;
  final TextEditingController phoneController;
  final bool isHighlight;
  final ValueChanged<bool> onHighlightChanged;

  static const Color accent = Color(0xFF8BC541);

  const StepPricing({
    super.key,
    required this.formKey,
    required this.priceController,
    required this.phoneController,
    required this.isHighlight,
    required this.onHighlightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Árazás & Kapcsolattartó',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: priceController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Ár (Ft / éjszaka)'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Telefonszám (pl. +36 30 123 4567)'),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            activeThumbColor: accent,
            contentPadding: EdgeInsets.zero,
            title: const Text('Kiemelt hirdetés', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('A hirdetésed megjelenik a kezdőlap kiemelt kártyái között.', style: TextStyle(color: Colors.white54, fontSize: 12)),
            value: isHighlight,
            onChanged: onHighlightChanged,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accent),
      ),
    );
  }
}