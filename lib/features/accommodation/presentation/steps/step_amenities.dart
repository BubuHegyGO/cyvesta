import 'package:flutter/material.dart';

class StepAmenities extends StatefulWidget {
  final int maxGuests;
  final int bedrooms;
  final int beds;
  final List<String> selectedAmenities;
  final Function(int) onGuestsChanged;
  final Function(int) onBedroomsChanged;
  final Function(int) onBedsChanged;
  final Function(String) onAmenityToggled;

  const StepAmenities({
    super.key,
    required this.maxGuests,
    required this.bedrooms,
    required this.beds,
    required this.selectedAmenities,
    required this.onGuestsChanged,
    required this.onBedroomsChanged,
    required this.onBedsChanged,
    required this.onAmenityToggled,
  });

  @override
  State<StepAmenities> createState() => _StepAmenitiesState();
}

class _StepAmenitiesState extends State<StepAmenities> {
  static const Color accent = Color(0xFF8BC541);

  // A választható felszereltségek listája ikonokkal
  final List<Map<String, dynamic>> _allAmenities = [
    {'title': 'Dézsafürdő', 'icon': Icons.hot_tub_rounded},
    {'title': 'Jakuzzi', 'icon': Icons.bathtub_outlined},
    {'title': 'Szauna', 'icon': Icons.spa_outlined},
    {'title': 'Wifi', 'icon': Icons.wifi_rounded},
    {'title': 'Kandalló', 'icon': Icons.local_fire_department_rounded},
    {'title': 'Panoráma', 'icon': Icons.landscape_rounded},
    {'title': 'Konyha', 'icon': Icons.kitchen_rounded},
    {'title': 'Ingyenes Parkolás', 'icon': Icons.directions_car_rounded},
    {'title': 'Kisállat hozható', 'icon': Icons.pets_rounded},
    {'title': 'Grillező / Bogrács', 'icon': Icons.outdoor_grill_rounded},
    {'title': 'Klíma', 'icon': Icons.ac_unit_rounded},
    {'title': 'Terasz / Erkély', 'icon': Icons.deck_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kapacitás és Felszereltség',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Még hány vendéget tudsz fogadni, és milyen kényelmi szolgáltatásokat nyújtasz?',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Kapacitás számlálók
          _buildCounterRow('Max. vendégek száma', widget.maxGuests, widget.onGuestsChanged),
          const SizedBox(height: 12),
          _buildCounterRow('Hálószobák száma', widget.bedrooms, widget.onBedroomsChanged),
          const SizedBox(height: 12),
          _buildCounterRow('Ágyak száma', widget.beds, widget.onBedsChanged),

          const SizedBox(height: 32),

          const Text(
            'Felszereltség & Jellemzők',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Ikonos választó elemek (Wrap / Chips)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _allAmenities.map((amenity) {
              final String title = amenity['title'];
              final IconData icon = amenity['icon'];
              final isSelected = widget.selectedAmenities.contains(title);

              return FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isSelected ? Colors.black : accent,
                    ),
                    const SizedBox(width: 8),
                    Text(title),
                  ],
                ),
                onSelected: (_) => widget.onAmenityToggled(title),
                selectedColor: accent,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? accent : Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Számláló sor gombokkal (+ / -)
  Widget _buildCounterRow(String title, int count, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              _buildCircleButton(
                icon: Icons.remove,
                onPressed: count > 1 ? () => onChanged(count - 1) : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$count',
                  style: const TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _buildCircleButton(
                icon: Icons.add,
                onPressed: () => onChanged(count + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, VoidCallback? onPressed}) {
    final isDisabled = onPressed == null;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDisabled ? Colors.white10 : accent.withValues(alpha: 0.2),
          border: Border.all(color: isDisabled ? Colors.white12 : accent),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDisabled ? Colors.white30 : accent,
        ),
      ),
    );
  }
}