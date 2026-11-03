import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/widgets/cyvesta_scaffold.dart';
import '../../core/services/auth_state.dart';

class HostRegistrationPage extends StatefulWidget {
  const HostRegistrationPage({super.key});

  @override
  State<HostRegistrationPage> createState() => _HostRegistrationPageState();
}

class _HostRegistrationPageState extends State<HostRegistrationPage> {
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  bool _isPartnerMode = false; // false = Vendég, true = Partner

  // Partner lenyíló kategória
  String _selectedCategory = 'Apartman, Villa';
  final List<String> _categories = [
    'Apartman, Villa',
    'Hotel',
    'Taxi',
    'Airport transzfer',
    'Busz',
    'Bevásárló üzletek',
    'Ajándék boltok',
    'Gyógyszertárak',
    'Túrák',
    'Rendezvények',
    'Sport',
    'Egyéb',
  ];

  // Vezérlők
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(); // WhatsApp / Telefon
  final _passwordController = TextEditingController();

  // Partner specifikus mezők
  final _businessNameController = TextEditingController();
  final _taxController = TextEditingController();
  final _licenseController = TextEditingController(); // Vállalkozási engedélyszám
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _customCategoryController = TextEditingController(); // Ha "Egyéb"

  bool _enableDirectChat = true; // Közvetlen chat opció
  bool _acceptedTerms = false;

  void _submitRegistration() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A regisztrációhoz el kell fogadni az ÁSZF-et és a GDPR-t! ⚠️'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty || _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kérjük, töltsd ki a kötelező mezőket! ⚠️'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (_isPartnerMode) {
      if (_phoneController.text.trim().isEmpty || _businessNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Partnerként a Vállalkozás neve és a Telefonszám/WhatsApp megadása kötelező! ⚠️'), backgroundColor: Colors.redAccent),
        );
        return;
      }
    }

    // Regisztráció végrehajtása AuthState-en keresztül
    final success = await AuthState.registerWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      asPartner: _isPartnerMode,
    );

    if (success) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: deepBlueIcon,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: mintGreenBorder, width: 1.4),
            ),
            title: const Text('Sikeres Regisztráció! 🎉', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: const Text(
              'A regisztrációs kérelmet rögzítettük. Az automatikus visszaigazoló e-mailt elküldtük a megadott címre.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: sunnyGold, foregroundColor: textDark),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context); // Vissza a főoldalra / profilra
                },
                child: const Text('Rendben', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hiba történt a regisztráció során! Ellenőrizze az adatokat.'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHotelOrApartment = _selectedCategory == 'Apartman, Villa' || _selectedCategory == 'Hotel';

    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        return CyvestaScaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vissza gomb és Címsor
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: deepBlueIcon,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: mintGreenBorder, size: 18),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'CYVESTA Fiók & Regisztráció 👤',
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Vendég / Partner Váltó Gombok
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isPartnerMode = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isPartnerMode ? mintGreenBorder : turquoiseGlass.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: mintGreenBorder, width: 1.4),
                            ),
                            child: Center(
                              child: Text(
                                'Vendég Fiók',
                                style: TextStyle(
                                  color: !_isPartnerMode ? textDark : Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isPartnerMode = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isPartnerMode ? mintGreenBorder : turquoiseGlass.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: mintGreenBorder, width: 1.4),
                            ),
                            child: Center(
                              child: Text(
                                'Partner Fiók',
                                style: TextStyle(
                                  color: _isPartnerMode ? textDark : Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // HA PARTNER MÓD VAN KIVÁLASZTVA: Kategória választó lenyíló
                  if (_isPartnerMode) ...[
                    const Text(
                      'Válassz kategóriát *',
                      style: TextStyle(color: sunnyGold, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF093753),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: mintGreenBorder, width: 1.2),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          dropdownColor: deepBlueIcon,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: sunnyGold),
                          items: _categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedCategory = val ?? 'Apartman, Villa');
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_selectedCategory == 'Egyéb') ...[
                      TextField(
                        controller: _customCategoryController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: _inputDec('Add meg a saját kategóriádat *', Icons.category_outlined),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],

                  // Személyes / Alapadatok
                  const Text(
                    'Személyes Adatok',
                    style: TextStyle(color: mintGreenBorder, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: _inputDec('Teljes Név *', Icons.person_outline),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: _inputDec('E-mail cím *', Icons.email_outlined),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: _inputDec(
                      _isPartnerMode ? 'Telefonszám vagy WhatsApp szám *' : 'Telefonszám (opcionális - később WhatsApp-ként is használható)',
                      Icons.phone_outlined,
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: _inputDec('Jelszó *', Icons.lock_outline),
                  ),
                  const SizedBox(height: 16),

                  // HA PARTNER MÓD: Céges adatok és extra mezők
                  if (_isPartnerMode) ...[
                    const Text(
                      'Vállalkozási Adatok',
                      style: TextStyle(color: mintGreenBorder, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: _businessNameController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: _inputDec('Vállalkozás Neve *', Icons.business_outlined),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: _taxController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: _inputDec('Adószám (opcionális)', Icons.receipt_long_outlined),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: _licenseController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: _inputDec('Vállalkozás Engedélyszám (opcionális)', Icons.badge_outlined),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: _websiteController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: _inputDec('Saját Weboldal Linkje (opcionális)', Icons.language_outlined),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: _addressController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: _inputDec('Cím / Helyszín Cipruson', Icons.location_on_outlined),
                    ),
                    const SizedBox(height: 14),

                    // Közvetlen chat opció kapcsoló
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF093753),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: mintGreenBorder.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Közvetlen chat lehetőség biztosítása',
                            style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                          Switch(
                            value: _enableDirectChat,
                            activeColor: sunnyGold,
                            onChanged: (val) => setState(() => _enableDirectChat = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (isHotelOrApartment)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          'ℹ️ Hotelek és Apartmanok számára a chat és a Push értesítések automatikusan aktívak.',
                          style: TextStyle(color: sunnyGold, fontSize: 11, fontStyle: FontStyle.italic),
                        ),
                      ),
                  ],

                  // ÁSZF Elfogadás
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        activeColor: sunnyGold,
                        checkColor: textDark,
                        onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
                      ),
                      const Expanded(
                        child: Text(
                          'Elfogadom az ÁSZF-et és a GDPR adatvédelmi nyilatkozatot. *',
                          style: TextStyle(color: mintGreenBorder, fontSize: 11.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Véglegesítés Gomb
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sunnyGold,
                        foregroundColor: textDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _submitRegistration,
                      child: const Text(
                        'Regisztráció Véglegesítése 🚀',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDec(String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF093753),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54, fontSize: 12),
      prefixIcon: Icon(icon, color: sunnyGold, size: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: mintGreenBorder, width: 1)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: mintGreenBorder.withValues(alpha: 0.3), width: 1)),
    );
  }
}