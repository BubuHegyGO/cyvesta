import 'package:flutter/material.dart';

class StepLocation extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController zipController;
  final TextEditingController cityController;
  final TextEditingController addressController;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String selectedRegion;
  final int maxGuests;
  final int bedrooms;
  final int beds;
  final ValueChanged<String?> onRegionChanged;
  final ValueChanged<int> onGuestsChanged;
  final ValueChanged<int> onBedroomsChanged;
  final ValueChanged<int> onBedsChanged;

  static const Color accent = Color(0xFF8BC541);

  final List<String> _regions = const [
    'Mátra', 'Bükk', 'Börzsöny', 'Zempléni-hegység', 'Cserhát',
    'Bakony', 'Pilis', 'Gerecse', 'Mecsek', 'Balaton-felvidék',
  ];

  const StepLocation({
    super.key,
    required this.formKey,
    required this.zipController,
    required this.cityController,
    required this.addressController,
    required this.titleController,
    required this.descriptionController,
    required this.selectedRegion,
    required this.maxGuests,
    required this.bedrooms,
    required this.beds,
    required this.onRegionChanged,
    required this.onGuestsChanged,
    required this.onBedroomsChanged,
    required this.onBedsChanged,
  });

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
          TextFormField(
            controller: titleController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Szálláshely neve (pl. Mátrai Kabin)'),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: selectedRegion,
            dropdownColor: const Color(0xFF07130A),
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Hegyvidék / Régió'),
            items: _regions.map((region) {
              return DropdownMenuItem(value: region, child: Text(region));
            }).toList(),
            onChanged: onRegionChanged,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 100,
                child: TextFormField(
                  controller: zipController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Irányítószám'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: cityController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Település (pl. Mátraháza)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: addressController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Utca, házszám / Helyrajzi szám'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: descriptionController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Rövid leírás a szállásról'),
          ),
          const SizedBox(height: 20),
          const Text(
            'Kapacitás',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildCounterRow('Vendégek max. száma', maxGuests, onGuestsChanged),
          _buildCounterRow('Hálószobák száma', bedrooms, onBedroomsChanged),
          _buildCounterRow('Ágyak száma', beds, onBedsChanged),
        ],
      ),
    );
  }

  Widget _buildCounterRow(String label, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: accent),
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
              ),
              Text(
                '$value',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: accent),
                onPressed: () => onChanged(value + 1),
              ),
            ],
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