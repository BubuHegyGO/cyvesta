import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/widgets/cyvesta_scaffold.dart';
import '../../core/services/auth_state.dart';
import '../../core/services/data_service.dart'; // <-- Hozzáadva

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  bool _isRegisterMode = true;
  bool _isPartnerMode = false;

  String _selectedCategoryKey = 'cat_partner_apartment';
  final List<String> _categoryKeys = [
    'cat_partner_apartment',
    'cat_partner_hotel',
    'cat_partner_taxi',
    'cat_partner_transfer',
    'cat_partner_bus',
    'cat_partner_shop',
    'cat_partner_gift',
    'cat_partner_pharmacy',
    'cat_partner_tour',
    'cat_partner_event',
    'cat_partner_sport',
    'cat_partner_other',
  ];

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _businessNameController = TextEditingController();
  final _taxController = TextEditingController();
  final _licenseController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _customCategoryController = TextEditingController();

  bool _enableDirectChat = true;
  bool _acceptedTerms = false;

  void _handleSubmit() async {
    if (_isRegisterMode && !_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A regisztrációhoz el kell fogadni az ÁSZF-et és a GDPR-t! ⚠️'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kérjük, add meg az E-mail címet és a jelszót! ⚠️'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (_isRegisterMode && _isPartnerMode && _businessNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Partnerként a Vállalkozás neve kötelező! ⚠️'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (_isRegisterMode) {
      final success = await AuthState.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Felhasználó',
        asPartner: _isPartnerMode,
      );

      if (success && mounted) {
        // --- Ha "Egyéb" volt kiválasztva és van beírt szöveg, elmentjük a DataService-be ---
        if (_isPartnerMode && _selectedCategoryKey == 'cat_partner_other' && _customCategoryController.text.trim().isNotEmpty) {
          DataService.addCustomCategory(_customCategoryController.text.trim());
        }

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
              'A regisztrációt rögzítettük. Az automatikus visszaigazoló e-mailt elküldtük a megadott címre.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: sunnyGold, foregroundColor: textDark),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Rendben', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
        setState(() {});
      }
    } else {
      final success = await AuthState.loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sikeres bejelentkezés! ✅'), backgroundColor: Colors.green),
        );
        setState(() {});
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Helytelen e-mail vagy jelszó! ⚠️'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = AuthState.isLoggedIn.value;
    final isHotelOrApartment = _selectedCategoryKey == 'cat_partner_apartment' || _selectedCategoryKey == 'cat_partner_hotel';

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
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: deepBlueIcon,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: mintGreenBorder, size: 18),
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushReplacementNamed(context, '/');
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLanguage.tr('profile_app_bar_title'),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  if (loggedIn) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: turquoiseGlass,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: mintGreenBorder, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: deepBlueIcon,
                                radius: 26,
                                child: Icon(Icons.person_rounded, color: sunnyGold, size: 30),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AuthState.userName.value,
                                      style: const TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.w900),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AuthState.userName.value.isNotEmpty ? AuthState.userName.value : AppLanguage.tr('profile_active_account'),
                                      style: TextStyle(color: textDark.withValues(alpha: 0.8), fontSize: 12.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: deepBlueIcon,
                                foregroundColor: mintGreenBorder,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.logout_rounded, size: 18),
                              label: Text(AppLanguage.tr('auth_logout_btn'), style: const TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () {
                                AuthState.logout();
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
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
                                  AppLanguage.tr('profile_guest_tab'),
                                  style: TextStyle(
                                    color: !_isPartnerMode ? textDark : Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13.5,
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
                                  AppLanguage.tr('profile_partner_tab'),
                                  style: TextStyle(
                                    color: _isPartnerMode ? textDark : Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => _isRegisterMode = true),
                          child: Text(
                            AppLanguage.tr('profile_tab_register'),
                            style: TextStyle(
                              color: _isRegisterMode ? sunnyGold : Colors.white60,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              decoration: _isRegisterMode ? TextDecoration.underline : TextDecoration.none,
                            ),
                          ),
                        ),
                        const Text('|', style: TextStyle(color: Colors.white38)),
                        TextButton(
                          onPressed: () => setState(() => _isRegisterMode = false),
                          child: Text(
                            AppLanguage.tr('profile_tab_login'),
                            style: TextStyle(
                              color: !_isRegisterMode ? sunnyGold : Colors.white60,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              decoration: !_isRegisterMode ? TextDecoration.underline : TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (_isRegisterMode && _isPartnerMode) ...[
                      Text(
                        AppLanguage.tr('reg_partner_category_label'),
                        style: const TextStyle(color: sunnyGold, fontSize: 13, fontWeight: FontWeight.bold),
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
                            value: _selectedCategoryKey,
                            isExpanded: true,
                            dropdownColor: deepBlueIcon,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: sunnyGold),
                            items: _categoryKeys.map((catKey) {
                              return DropdownMenuItem(
                                value: catKey,
                                child: Text(
                                  AppLanguage.tr(catKey),
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _selectedCategoryKey = val ?? 'cat_partner_apartment');
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (_selectedCategoryKey == 'cat_partner_other') ...[
                        TextField(
                          controller: _customCategoryController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: _inputDec(AppLanguage.tr('reg_custom_cat_hint'), Icons.category_outlined),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],

                    if (_isRegisterMode) ...[
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: _inputDec(AppLanguage.tr('auth_name_hint'), Icons.person_outline),
                      ),
                      const SizedBox(height: 10),
                    ],

                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: _inputDec(AppLanguage.tr('auth_email_hint'), Icons.email_outlined),
                    ),
                    const SizedBox(height: 10),

                    if (_isRegisterMode) ...[
                      TextField(
                        controller: _phoneController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: _inputDec(AppLanguage.tr('auth_phone_hint'), Icons.phone_outlined),
                      ),
                      const SizedBox(height: 10),
                    ],

                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: _inputDec(AppLanguage.tr('auth_password_hint'), Icons.lock_outline),
                    ),
                    const SizedBox(height: 10),

                    if (_isRegisterMode && _isPartnerMode) ...[
                      const SizedBox(height: 6),
                      Text(
                        AppLanguage.tr('profile_business_data_title'),
                        style: const TextStyle(color: mintGreenBorder, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: _businessNameController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: _inputDec(AppLanguage.tr('profile_business_name_hint'), Icons.business_outlined),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: _taxController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: _inputDec(AppLanguage.tr('profile_tax_hint'), Icons.receipt_long_outlined),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: _licenseController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: _inputDec(AppLanguage.tr('profile_license_hint'), Icons.badge_outlined),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: _websiteController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: _inputDec(AppLanguage.tr('profile_website_hint'), Icons.language_outlined),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: _addressController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: _inputDec(AppLanguage.tr('profile_address_hint'), Icons.location_on_outlined),
                      ),
                      const SizedBox(height: 12),

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
                            Text(
                              AppLanguage.tr('profile_direct_chat_label'),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            Switch(
                              value: _enableDirectChat,
                              activeColor: sunnyGold,
                              onChanged: (val) => setState(() => _enableDirectChat = val),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      if (isHotelOrApartment)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'ℹ️ Hotelek és Apartmanok számára a chat és a Push értesítések automatikusan aktívak.',
                            style: TextStyle(color: sunnyGold, fontSize: 11, fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],

                    if (_isRegisterMode) ...[
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptedTerms,
                            activeColor: sunnyGold,
                            checkColor: textDark,
                            onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
                          ),
                          Expanded(
                            child: Text(
                              AppLanguage.tr('terms_acceptance'),
                              style: const TextStyle(color: mintGreenBorder, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: sunnyGold,
                          foregroundColor: textDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _handleSubmit,
                        child: Text(
                          _isRegisterMode ? AppLanguage.tr('profile_register_btn_text') : AppLanguage.tr('auth_login_btn'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
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