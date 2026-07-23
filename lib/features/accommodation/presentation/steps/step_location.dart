import 'package:flutter/material.dart';

class StepLocation extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController zipController;
  final TextEditingController cityController;
  final TextEditingController addressController;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController ntakController;
  final String selectedRegion;
  final int maxGuests;
  final int bedrooms;
  final int beds;
  final ValueChanged<String?> onRegionChanged;
  final ValueChanged<int> onGuestsChanged;
  final ValueChanged<int> onBedroomsChanged;
  final ValueChanged<int> onBedsChanged;

  const StepLocation({
    super.key,
    required this.formKey,
    required this.zipController,
    required this.cityController,
    required this.addressController,
    required this.titleController,
    required this.descriptionController,
    required this.ntakController,
    required this.selectedRegion,
    required this.maxGuests,
    required this.bedrooms,
    required this.beds,
    required this.onRegionChanged,
    required this.onGuestsChanged,
    required this.onBedroomsChanged,
    required this.onBedsChanged,
  });

  static const Color accent = Color(0xFF8BC541);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Helyszín & Alapadatok',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Kötelező NTAK szám mező
          TextFormField(
            controller: ntakController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'NTAK regisztrációs szám *',
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: 'pl. EG12345678',
              hintStyle: const TextStyle(color: Colors.white30),
              prefixIcon: const Icon(Icons.verified_user_rounded, color: accent),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: accent, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Az NTAK regisztrációs szám megadása kötelező!';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Szállás neve
          TextFormField(
            controller: titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Szállás megnevezése *',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.home_rounded, color: accent),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: accent, width: 2),
              ),
            ),
            validator: (value) => (value == null || value.isEmpty) ? 'Kérjük add meg a szállás nevét' : null,
          ),
          const SizedBox(height: 16),

          // Régió választó (Modern initialValue paraméterrel)
          DropdownButtonFormField<String>(
            initialValue: selectedRegion,
            dropdownColor: const Color(0xFF07130A),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Tájegység / Régió *',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.landscape_rounded, color: accent),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white24),
              ),
            ),
            items: ['Mátra', 'Bükk', 'Zemplén', 'Börzsöny', 'Mecsek', 'Bakony']
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: onRegionChanged,
          ),
          const SizedBox(height: 16),

          // Irányítószám & Város
          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: zipController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Irányítószám',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: cityController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Település *',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Kötelező' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Utca, házszám
          TextFormField(
            controller: addressController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Cím (utca, házszám)',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.location_on_rounded, color: accent),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white24),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Leírás
          TextFormField(
            controller: descriptionController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Szállás leírása',
              labelStyle: const TextStyle(color: Colors.white70),
              alignLabelWithHint: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}