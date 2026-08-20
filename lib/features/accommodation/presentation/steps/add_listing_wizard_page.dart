import 'package:flutter/material.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/services/data_service.dart';
import '../../../../core/widgets/cyvesta_scaffold.dart';

class AddListingWizardPage extends StatefulWidget {
  const AddListingWizardPage({super.key});

  @override
  State<AddListingWizardPage> createState() => _AddListingWizardPageState();
}

class _AddListingWizardPageState extends State<AddListingWizardPage> {
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  int _currentStep = 1; // 1-től 5-ig

  // Step 1: Alapadatok & Partner által választott Kategória
  String _mainCategory = 'accommodation'; // 'accommodation', 'experience', 'gastronomy', 'transfer', 'rent_car'
  String _purpose = 'rent'; // 'rent' vagy 'sale'
  String _propertyType = 'villa';
  final _titleController = TextEditingController();
  final _regNumController = TextEditingController();
  int _guests = 4;
  int _bedrooms = 2;
  int _bathrooms = 2;

  // Step 2: Helyszín & Régió
  String _selectedRegion = 'paphos';
  final _addressController = TextEditingController();
  final _distanceToBeachController = TextEditingController();

  // Step 3: Árak & Naptár (iCal)
  final _priceController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _websiteController = TextEditingController();
  final _icalUrlController = TextEditingController();

  // Step 4: Képek & Média
  final List<String> _uploadedImages = [
    'assets/images/szarvas.png',
    'assets/images/yacht.png',
    'assets/images/etterem.png',
  ];

  // Step 5: Felszereltség & Leírás
  final _descController = TextEditingController();
  final Map<String, bool> _amenities = {
    'Saját Medence 🏊': true,
    'Tengeri Panoráma 🌊': true,
    'Nagysebességű Wi-Fi 📶': true,
    'Klímaberendezés ❄️': true,
    'Ingyenes Parkoló 🚗': true,
    'Kerti Grill & BBQ 🍖': false,
    'Okos TV & Netflix 📺': true,
    'Mosógép & Szárító 🧺': false,
  };

  final List<Map<String, String>> _regions = const [
    {'id': 'paphos', 'name': 'Paphos & Coral Bay 🏖️'},
    {'id': 'kyrenia', 'name': 'Kyrenia (Girne) 🏰'},
    {'id': 'limassol', 'name': 'Limassol & Akrotiri 🌴'},
    {'id': 'larnaca', 'name': 'Larnaca & Ayia Napa ⛵'},
    {'id': 'famagusta', 'name': 'Famagusta & Long Beach 🌊'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _regNumController.dispose();
    _addressController.dispose();
    _distanceToBeachController.dispose();
    _priceController.dispose();
    _whatsappController.dispose();
    _websiteController.dispose();
    _icalUrlController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    } else {
      _finishListing();
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  void _finishListing() {
    final newListing = {
      'id': 'wizard_${DateTime.now().millisecondsSinceEpoch}',
      'category': _mainCategory,
      'title': _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : 'Cyprus Featured Listing',
      'location': _regions.firstWhere((r) => r['id'] == _selectedRegion)['name'],
      'price': _purpose == 'rent' ? '€${_priceController.text.trim()} / éj' : '€${_priceController.text.trim()}',
      'rating': '5.0',
      'imagePath': _uploadedImages.isNotEmpty ? _uploadedImages.first : 'assets/images/szarvas.png',
      'whatsapp': _whatsappController.text.trim(),
      'phone': _whatsappController.text.trim(),
      'website': _websiteController.text.trim(),
      'ical_url': _icalUrlController.text.trim(),
      'description': _descController.text.trim(),
      'status': 'pending',
    };

    DataService.addListing(newListing);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: deepBlueIcon,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: mintGreenBorder, width: 1.5)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: mintGreenBorder, size: 28),
            SizedBox(width: 10),
            Text('Hirdetés Beküldve!', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
        content: const Text(
          'A hirdetés sikeresen elmentve!\n\nAz adminisztrátori moderáció után azonnal megjelenik a megfelelő kategóriában a mobilos alkalmazásban. 🚀',
          style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: sunnyGold, foregroundColor: textDark),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Rendben, Vissza', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        return CyvestaScaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Fejléc
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: deepBlueIcon,
                    border: Border(bottom: BorderSide(color: mintGreenBorder.withValues(alpha: 0.3))),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF093753),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, color: mintGreenBorder, size: 18),
                              onPressed: _prevStep,
                            ),
                          ),
                          Text(
                            '$_currentStep / 5 • ${_getStepTitle(_currentStep)}',
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: List.generate(5, (index) {
                          final stepNum = index + 1;
                          final isPassed = stepNum <= _currentStep;
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              height: 5,
                              decoration: BoxDecoration(
                                color: isPassed ? sunnyGold : Colors.white24,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                // Lépések nézete
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildCurrentStepView(),
                  ),
                ),

                // Alsó gomb
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: deepBlueIcon,
                    border: Border(top: BorderSide(color: mintGreenBorder.withValues(alpha: 0.3))),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sunnyGold,
                        foregroundColor: textDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _nextStep,
                      child: Text(
                        _currentStep == 5 ? 'Hirdetés Véglegesítése & Beküldése 🚀' : 'Tovább a következő lépésre ➔',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 1:
        return 'Kategória & Típus';
      case 2:
        return 'Helyszín & Régió';
      case 3:
        return 'Árak, WhatsApp & iCal';
      case 4:
        return 'Fotógaléria Feltöltése';
      case 5:
        return 'Felszereltség & Leírás';
      default:
        return '';
    }
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      case 5:
        return _buildStep5();
      default:
        return const SizedBox();
    }
  }

  // 1. LÉPÉS: PARTNER ÁLTAL VÁLASZTOTT FŐKATEGÓRIA ÉS TÍPUS
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Hirdetés Főkategóriája *'),
        const Text(
          'Válaszd ki, hogy milyen típusú szolgáltatást vagy ingatlant szeretnél hirdetni a CYVESTA platformon:',
          style: TextStyle(color: Colors.white70, fontSize: 11.5),
        ),
        const SizedBox(height: 10),

        // Főkategória választó rács
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildMainCatChip('Szállás / Villa 🏖️', 'accommodation', Icons.apartment_rounded),
            _buildMainCatChip('Élmény & Túra ⛵', 'experience', Icons.sailing_rounded),
            _buildMainCatChip('Gasztronómia 🍽️', 'gastronomy', Icons.restaurant_rounded),
            _buildMainCatChip('Reptéri Transzfer 🚖', 'transfer', Icons.directions_car_rounded),
            _buildMainCatChip('Autóbérlés 🚗', 'rent_car', Icons.car_rental_rounded),
          ],
        ),
        const SizedBox(height: 16),

        if (_mainCategory == 'accommodation') ...[
          _buildSectionTitle('Hirdetés Célja *'),
          Row(
            children: [
              Expanded(child: _buildChoiceBtn('Kiadó Szállás 🏖️', _purpose == 'rent', () => setState(() => _purpose = 'rent'))),
              const SizedBox(width: 8),
              Expanded(child: _buildChoiceBtn('Eladó Ingatlan 🔑', _purpose == 'sale', () => setState(() => _purpose = 'sale'))),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Ingatlan Típusa *'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSmallChoiceBtn('Villa 🏡', _propertyType == 'villa', () => setState(() => _propertyType = 'villa')),
              _buildSmallChoiceBtn('Apartman 🏢', _propertyType == 'apartment', () => setState(() => _propertyType = 'apartment')),
              _buildSmallChoiceBtn('Penthouse 🌴', _propertyType == 'penthouse', () => setState(() => _propertyType = 'penthouse')),
              _buildSmallChoiceBtn('Stúdió 🛋️', _propertyType == 'studio', () => setState(() => _propertyType = 'studio')),
            ],
          ),
          const SizedBox(height: 16),
        ],

        _buildSectionTitle('Hirdetés Címe *'),
        TextField(
          controller: _titleController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: _inputDec('Pl. Blue Lagoon Catamaran Cruise / Lordos Villa', Icons.title_rounded),
        ),
        const SizedBox(height: 12),

        if (_mainCategory == 'accommodation') ...[
          _buildSectionTitle('Férőhely és Helyiségek Száma'),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF093753),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: mintGreenBorder.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCounter('Vendégek', _guests, (v) => setState(() => _guests = v)),
                _buildCounter('Szobák', _bedrooms, (v) => setState(() => _bedrooms = v)),
                _buildCounter('Fürdők', _bathrooms, (v) => setState(() => _bathrooms = v)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // 2. LÉPÉS: HELYSZÍN & RÉGIÓ
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Ciprusi Régió / Város *'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF093753),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: mintGreenBorder.withValues(alpha: 0.4)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRegion,
              isExpanded: true,
              dropdownColor: const Color(0xFF072A40),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
              items: _regions.map((r) => DropdownMenuItem<String>(
                value: r['id'],
                child: Text(r['name']!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              )).toList(),
              onChanged: (val) => setState(() => _selectedRegion = val ?? 'paphos'),
            ),
          ),
        ),
        const SizedBox(height: 16),

        _buildSectionTitle('Pontos Cím / Kikötő / Kiindulási Pont'),
        TextField(
          controller: _addressController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: _inputDec('Pl. Latchi Harbor, Paphos / Coral Bay', Icons.location_on_outlined),
        ),
        const SizedBox(height: 14),

        _buildSectionTitle('Távolság a Strandtól vagy Városközponttól'),
        TextField(
          controller: _distanceToBeachController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: _inputDec('Pl. Közvetlen tengerpart / 200m', Icons.beach_access_rounded),
        ),
      ],
    );
  }

  // 3. LÉPÉS: ÁRAK, WHATSAPP ÉS ICAL
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Ár / Díjszabás (€) *'),
        TextField(
          controller: _priceController,
          keyboardType: TextInputType.text,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: _inputDec('Pl. 45 / fő vagy 180 / éj', Icons.euro_rounded),
        ),
        const SizedBox(height: 14),

        _buildSectionTitle('WhatsApp Telefonszám (Közvetlen foglalásokhoz) *'),
        TextField(
          controller: _whatsappController,
          keyboardType: TextInputType.text,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: _inputDec('Pl. +357 99 123456', Icons.chat_rounded),
        ),
        const SizedBox(height: 14),

        _buildSectionTitle('Saját Weboldal Címe (opcionális)'),
        TextField(
          controller: _websiteController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: _inputDec('Pl. www.cyprusboatcruise.com', Icons.language_rounded),
        ),
        const SizedBox(height: 14),

        if (_mainCategory == 'accommodation') ...[
          _buildSectionTitle('iCal Naptár Link (Airbnb / Booking - Opcionális)'),
          TextField(
            controller: _icalUrlController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: _inputDec('Airbnb vagy Booking .ics naptár link', Icons.sync_rounded),
          ),
        ],
      ],
    );
  }

  // 4. LÉPÉS: FOTÓGALÉRIA
  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Fényképek Hozzáadása'),
        const Text(
          'Tölts fel látványos képeket, amelyek felkeltik az utazók figyelmét.',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () {
            setState(() {
              _uploadedImages.add('assets/images/yacht.png');
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kép sikeresen hozzáadva! 📸')),
            );
          },
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF093753),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: sunnyGold, width: 1.5),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_rounded, color: sunnyGold, size: 36),
                SizedBox(height: 6),
                Text('Kattints ide fotó feltöltéséhez', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('Feltöltött Fotók (${_uploadedImages.length} db)'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: _uploadedImages.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(_uploadedImages[index], width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => setState(() => _uploadedImages.removeAt(index)),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // 5. LÉPÉS: FELSZERELTSÉG & LEÍRÁS
  Widget _buildStep5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Felszereltség / Szolgáltatások'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _amenities.keys.map((key) {
            final isChecked = _amenities[key] ?? false;
            return FilterChip(
              label: Text(key, style: TextStyle(color: isChecked ? textDark : Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
              selected: isChecked,
              selectedColor: mintGreenBorder,
              backgroundColor: const Color(0xFF093753),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: isChecked ? Colors.white : mintGreenBorder.withValues(alpha: 0.3))),
              onSelected: (val) => setState(() => _amenities[key] = val),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('Részletes Ismertető *'),
        TextField(
          controller: _descController,
          maxLines: 5,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: _inputDec('Írd le részletesen a programot, a kényelmi szolgáltatásokat vagy az ételeket...', Icons.notes_rounded),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMainCatChip(String label, String value, IconData icon) {
    final isSelected = _mainCategory == value;
    return GestureDetector(
      onTap: () => setState(() => _mainCategory = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? sunnyGold : const Color(0xFF093753),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.white : mintGreenBorder.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? textDark : mintGreenBorder, size: 18),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: isSelected ? textDark : Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceBtn(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? sunnyGold : const Color(0xFF093753),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.white : mintGreenBorder.withValues(alpha: 0.4)),
        ),
        child: Center(
          child: Text(label, style: TextStyle(color: isSelected ? textDark : Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildSmallChoiceBtn(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? mintGreenBorder : const Color(0xFF093753),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.white : mintGreenBorder.withValues(alpha: 0.3)),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? textDark : Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCounter(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 6),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                if (value > 1) onChanged(value - 1);
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(color: deepBlueIcon, shape: BoxShape.circle),
                child: const Icon(Icons.remove, color: Colors.white, size: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('$value', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            GestureDetector(
              onTap: () => onChanged(value + 1),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(color: deepBlueIcon, shape: BoxShape.circle),
                child: const Icon(Icons.add, color: mintGreenBorder, size: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _inputDec(String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF093753),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54, fontSize: 11.5),
      prefixIcon: Icon(icon, color: sunnyGold, size: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: mintGreenBorder, width: 1)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: mintGreenBorder.withValues(alpha: 0.4), width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: sunnyGold, width: 1.5)),
    );
  }
}