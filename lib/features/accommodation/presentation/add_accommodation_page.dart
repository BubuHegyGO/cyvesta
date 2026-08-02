import 'package:flutter/material.dart';

class AddAccommodationPage extends StatefulWidget {
  const AddAccommodationPage({super.key});

  @override
  State<AddAccommodationPage> createState() => _AddAccommodationPageState();
}

class _AddAccommodationPageState extends State<AddAccommodationPage> {
  int _currentStep = 0;
  final _formKey1 = GlobalKey<FormState>();

  // --- CONTROLLEREK ---
  final _ntakController = TextEditingController();
  final _titleController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController(); // Saját weboldal

  String _selectedRegion = 'Mátra';
  bool _isFeatured = false;

  final List<String> _regions = [
    'Mátra', 'Bükk', 'Börzsöny', 'Zempléni-hegység', 'Cserhát',
    'Aggteleki-karszt', 'Bakony', 'Pilis', 'Gerecse', 'Vértes',
    'Budai-hegység', 'Visegrádi-hegység', 'Velencei-hegység',
    'Kőszegi-hegység', 'Soproni-hegység', 'Mecsek', 'Villányi-hegység'
  ];

  final Map<String, bool> _amenities = {
    'Dézsafürdő': false,
    'Finn Szauna': false,
    'Panoráma Terasz': false,
    'Kandalló / Cserépkályha': false,
    'Grillező / Bográcsozó': false,
    'Wifi': false,
    'Klímaberendezés': false,
    'Ingyenes Parkolás': false,
    'Kutyabarát': false,
    'E-bike Töltő': false,
    'Jakuzzi': false,
    'Gyerekbarát': false,
  };

  @override
  void dispose() {
    _ntakController.dispose();
    _titleController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _showWebsiteOfferDialog() {
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
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey1.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _submitForm();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _submitForm() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hirdetés sikeresen beküldve!'),
        backgroundColor: Color(0xFF8BC541),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D160E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D160E),
        elevation: 0,
        title: const Text(
          'Új szállás feladása 🏡',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // LÉPÉSEK INDIKÁTOR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentStep ? const Color(0xFF8BC541) : Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getStepTitle(_currentStep),
                    style: const TextStyle(color: Color(0xFF8BC541), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    '${_currentStep + 1} / 4',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // KÉPERNYŐK TARTALMA
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildStepContent(_currentStep),
              ),
            ),

            // ALSÓ NAVIGÁCIÓS GOMBOK
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black,
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white38),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _previousStep,
                        child: const Text('Vissza', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8BC541),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _nextStep,
                      child: Text(
                        _currentStep == 3 ? 'Hirdetés Beküldése' : 'Tovább',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0: return '1. Lépés: Alapadatok & Helyszín';
      case 1: return '2. Lépés: Felszereltség';
      case 2: return '3. Lépés: Képek feltöltése';
      case 3: return '4. Lépés: Árazás & Kapcsolat';
      default: return '';
    }
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0: return _buildStep1();
      case 1: return _buildStep2();
      case 2: return _buildStep3();
      case 3: return _buildStep4();
      default: return const SizedBox();
    }
  }

  // 1. LÉPÉS
  Widget _buildStep1() {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Helyszín & Alapadatok', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTextField(_ntakController, 'NTAK regisztrációs szám *', Icons.verified, required: true),
          const SizedBox(height: 12),
          _buildTextField(_titleController, 'Szállás megnevezése *', Icons.home, required: true),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedRegion,
            dropdownColor: const Color(0xFF1E261C),
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Tájegység / Régió *', Icons.landscape),
            items: _regions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (val) => setState(() => _selectedRegion = val!),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField(_zipController, 'Irányítószám', null)),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: _buildTextField(_cityController, 'Település *', null, required: true)),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(_addressController, 'Cím (utca, házszám)', Icons.location_on),
          const SizedBox(height: 12),
          _buildTextField(_descriptionController, 'Szállás leírása', null, maxLines: 4),
        ],
      ),
    );
  }

  // 2. LÉPÉS
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Felszereltség & Szolgáltatások', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: _amenities.keys.map((key) {
            final isSelected = _amenities[key]!;
            return ChoiceChip(
              label: Text(key),
              selected: isSelected,
              selectedColor: const Color(0xFF8BC541),
              backgroundColor: Colors.white12,
              labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              onSelected: (val) => setState(() => _amenities[key] = val),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 3. LÉPÉS
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Képek feltöltése', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF8BC541), style: BorderStyle.solid),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, color: Color(0xFF8BC541), size: 40),
              SizedBox(height: 8),
              Text('Kattints a fotók hozzáadásához', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  // 4. LÉPÉS (AUTOMATIKUSAN FELUGRÓ POPUP RÁKATTINTÁSKOR)
  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Árazás & Kapcsolattartó', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildTextField(_priceController, 'Ár (Ft / éjszaka)', Icons.payments, keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        _buildTextField(_phoneController, 'Telefonszám (pl. +36 30 123 4567)', Icons.phone, keyboardType: TextInputType.phone),
        const SizedBox(height: 12),

        // SAJÁT WEBOLDAL MEZŐ -> RÁKATTINTÁSKOR (onTap) AZONNAL POPUP
        TextFormField(
          controller: _websiteController,
          style: const TextStyle(color: Colors.white),
          onTap: _showWebsiteOfferDialog,
          decoration: InputDecoration(
            labelText: 'Saját weboldal (Opcionális)',
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.language, color: Color(0xFF8BC541)),
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

        const SizedBox(height: 20),
        SwitchListTile(
          value: _isFeatured,
          activeColor: const Color(0xFF8BC541),
          title: const Text('Kiemelt hirdetés', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: const Text('A hirdetésed megjelenik a kezdőlap kiemelt kártyái között.', style: TextStyle(color: Colors.white54, fontSize: 12)),
          onChanged: (val) => setState(() => _isFeatured = val),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData? icon, {bool required = false, int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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