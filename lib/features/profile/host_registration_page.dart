import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/widgets/cyvesta_scaffold.dart';
import '../../core/localization/app_language.dart';

class HostRegistrationPage extends StatefulWidget {
  const HostRegistrationPage({super.key});

  @override
  State<HostRegistrationPage> createState() => _HostRegistrationPageState();
}

class _HostRegistrationPageState extends State<HostRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyDataController = TextEditingController();
  final _customCategoryController = TextEditingController(); 

  bool _isCompany = false;
  bool _isLoading = false;

  // Kategória lista
  String _selectedCategory = 'Apartman / Villa';
  final List<String> _categories = [
    'Apartman / Villa',
    'Szálloda / Hotel',
    'Étterem / Kávézó',
    'Túra / Program',
    'Autókölcsönző',
    'Egyéb (Saját kategória megadása)',
  ];

  // Fotókezelés (Max 10 db)
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 10 darab fotó tölthető fel! ⚠️')),
      );
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          for (var img in images) {
            if (_selectedImages.length < 10) {
              _selectedImages.add(img);
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Képválasztási hiba: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyDataController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final finalCategory = _selectedCategory.contains('Egyéb') 
          ? _customCategoryController.text.trim() 
          : _selectedCategory;

      // Itt mentjük a hirdetést / partnert és a fotókat a backendre / Firebase-be
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sikeres adatrögzítés! Kategória: $finalCategory | Fotók száma: ${_selectedImages.length}'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CyvestaScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Partner Regisztráció & Adatmegadás',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Név (Kötelező)
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Teljes név *'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'A név megadása kötelező!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // E-mail (Kötelező)
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('E-mail cím (Validáláshoz) *'),
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Érvényes e-mail címet adjon meg!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Elérhetőség / Telefonszám (Kötelező)
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Telefonszám / Elérhetőség *'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'A telefonszám megadása kötelező!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Kategória Változó / Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  dropdownColor: const Color(0xFF072A40),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: _inputDecoration('Vállalkozás / Szolgáltatás Típusa *'),
                  items: _categories.map((String cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 14),

                // Ha az "Egyéb" opciót választotta, jelenjen meg a szabad szöveges mező
                if (_selectedCategory.contains('Egyéb')) ...[
                  TextFormField(
                    controller: _customCategoryController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Írja be a saját kategóriáját (pl. fagyizó, fodrász) *'),
                    validator: (value) {
                      if (_selectedCategory.contains('Egyéb') && (value == null || value.trim().isEmpty)) {
                        return 'Kérjük, adja meg a saját kategóriáját!';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                ],

                // Céges partner kapcsoló
                SwitchListTile(
                  title: const Text(
                    'Céges partner vagyok',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  value: _isCompany,
                  onChanged: (bool value) {
                    setState(() {
                      _isCompany = value;
                    });
                  },
                  activeColor: Colors.amber,
                ),
                const SizedBox(height: 14),

                // Hivatalos cégadatok / Regisztrációs szám (Csak ha céges)
                if (_isCompany) ...[
                  TextFormField(
                    controller: _companyDataController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Hivatalos cégadatok / Reg. szám *'),
                    validator: (value) {
                      if (_isCompany && (value == null || value.trim().isEmpty)) {
                        return 'Céges partnerként a cégadatok megadása kötelező!';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                ],

                // FOTÓ FELTÖLTÉS SZEKCIÓ (Max 10 db)
                const Text(
                  'Fényképek feltöltése (Max. 10 db)',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._selectedImages.asMap().entries.map((entry) {
                      int idx = entry.key;
                      XFile image = entry.value;
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(image.path),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () => _removeImage(idx),
                              child: Container(
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.close, color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    if (_selectedImages.length < 10)
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF093753),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF99FF99), width: 1.5),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_rounded, color: Color(0xFFFF9F1C), size: 28),
                              SizedBox(height: 4),
                              Text('Fotó', style: TextStyle(color: Colors.white70, fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Mentés / Küldés gomb
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9F1C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Regisztráció & Validálás',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF093753),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF99FF99), width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF99FF99), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF9F1C), width: 2.0),
      ),
    );
  }
}