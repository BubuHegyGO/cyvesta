import 'package:flutter/material.dart';

class StepLocation extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController zipController;
  final TextEditingController cityController;
  final TextEditingController addressController;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController ntakController;
  final TextEditingController websiteController;
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
    required this.websiteController,
    required this.selectedRegion,
    required this.maxGuests,
    required this.bedrooms,
    required this.beds,
    required this.onRegionChanged,
    required this.onGuestsChanged,
    required this.onBedroomsChanged,
    required this.onBedsChanged,
  });

  static const List<String> regions = [
    'Mátra', 'Bükk', 'Börzsöny', 'Zempléni-hegység', 'Cserhát',
    'Aggteleki-karszt', 'Bakony', 'Pilis', 'Gerecse', 'Vértes',
    'Budai-hegység', 'Visegrádi-hegység', 'Velencei-hegység',
    'Kőszegi-hegység', 'Soproni-hegység', 'Mecsek', 'Villányi-hegység'
  ];

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

          // NTAK
          _buildTextField(ntakController, 'NTAK regisztrációs szám *', Icons.verified, required: true),
          const SizedBox(height: 12),

          // MEGNEVEZÉS
          _buildTextField(titleController, 'Szállás megnevezése *', Icons.home, required: true),
          const SizedBox(height: 12),

          // TÁJEGYSÉG / RÉGIÓ
          DropdownButtonFormField<String>(
            value: selectedRegion,
            dropdownColor: const Color(0xFF1E261C),
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Tájegység / Régió *', Icons.landscape),
            items: regions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: onRegionChanged,
          ),
          const SizedBox(height: 12),

          // SAJÁT WEBOLDAL MEZŐ + PONTOS POP-UP
          TextFormField(
            controller: websiteController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Saját weboldal (Opcionális)',
              labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
              prefixIcon: const Icon(Icons.language, color: Color(0xFF8BC541), size: 20),
              suffixIcon: IconButton(
                icon: const Icon(Icons.info_outline, color: Color(0xFF8BC541)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1E261C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Color(0xFF8BC541), width: 1.5),
                      ),
                      title: const Row(
                        children: [
                          Icon(Icons.language, color: Color(0xFF8BC541), size: 28),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Nincs még saját weboldalad?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      content: const Text(
                        'Amennyiben nincs még saját weboldalad, a HegyGO csapata elkészíti Neked 25.000 Ft. (tárhely+domain)+havi 5000 Ft. (support díj) áron!\n\nBővebb információ: info@hegygo.hu',
                        style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Rendben, köszönöm',
                            style: TextStyle(
                              color: Color(0xFF8BC541),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              filled: true,
              fillColor: Colors.black26,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF8BC541)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // IRÁNYÍTÓSZÁM & TELEPÜLÉS
          Row(
            children: [
              Expanded(child: _buildTextField(zipController, 'Irányítószám', null)),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: _buildTextField(cityController, 'Település *', null, required: true)),
            ],
          ),
          const SizedBox(height: 12),

          // CÍM
          _buildTextField(addressController, 'Cím (utca, házszám)', Icons.location_on),
          const SizedBox(height: 12),

          // LEÍRÁS
          _buildTextField(descriptionController, 'Szállás leírása', null, maxLines: 4),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData? icon, {bool required = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: required ? (val) => val == null || val.isEmpty ? 'Ez a mező kötelező' : null : null,
      decoration: _inputDecoration(label, icon),
    );
  }

  InputDecoration _inputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF8BC541), size: 20) : null,
      filled: true,
      fillColor: Colors.black26,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF8BC541))),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
    );
  }
}