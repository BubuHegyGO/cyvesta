import 'package:flutter/material.dart';

class StepAmenities extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final List<String> selectedAmenities;
  final ValueChanged<List<String>> onAmenitiesChanged;

  const StepAmenities({
    super.key,
    required this.formKey,
    required this.selectedAmenities,
    required this.onAmenitiesChanged,
  });

  @override
  State<StepAmenities> createState() => _StepAmenitiesState();
}

class _StepAmenitiesState extends State<StepAmenities> {
  static const Color accent = Color(0xFF8BC541);

  final List<String> _allAmenities = const [
    'Dézsafürdő', 'Finn Szauna', 'Panorama Terasz', 'Kandalló / Cserépkályha',
    'Grillező / Bográcsozó', 'Wifi', 'Klímaberendezés', 'Ingyenes Parkolás',
    'Kutyabarát', 'E-bike Töltő', 'Jakuzzi', 'Gyerekbarát',
  ];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Felszereltség & Szolgáltatások',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: _allAmenities.map((amenity) {
              final isSelected = widget.selectedAmenities.contains(amenity);
              return FilterChip(
                label: Text(amenity),
                selected: isSelected,
                selectedColor: accent,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(color: isSelected ? accent : Colors.white24),
                onSelected: (selected) {
                  final updatedList = List<String>.from(widget.selectedAmenities);
                  if (selected) {
                    updatedList.add(amenity);
                  } else {
                    updatedList.remove(amenity);
                  }
                  widget.onAmenitiesChanged(updatedList);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}