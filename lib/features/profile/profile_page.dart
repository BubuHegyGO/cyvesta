import '../accommodation/presentation/my_listings_page.dart';
import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/widgets/auth_dialogs.dart';
import '../../core/widgets/cyvesta_scaffold.dart';
import '../accommodation/presentation/steps/add_listing_wizard_page.dart';
import '../../core/services/auth_state.dart';
import '../../core/services/data_service.dart';
import '../../core/services/partner_verification_service.dart';
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

  // --- Kétutas partner validációhoz szükséges állapotok ---
  String _partnerIdentifierType = 'HE'; // 'HE' vagy 'VAT'
  bool _isPartnerVerified = false;
  String? _partnerVerificationMsg;
  bool _isVerifyingPartner = false;

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

  // --- Partner azonosító ellenőrző funkció ---
  Future<void> _verifyPartnerIdentifier() async {
    final identifier = _partnerIdentifierType == 'HE' ? _licenseController.text.trim() : _taxController.text.trim();

    if (identifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kérjük, add meg az azonosítószámot az ellenőrzéshez! ⚠️'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      _isVerifyingPartner = true;
      _partnerVerificationMsg = null;
    });

    // Gyors előellenőrzés. A VÉGLEGES ellenőrzés a szerveren fut (VIES + admin), ez csak azonnali visszajelzés.
    if (_partnerIdentifierType == 'VAT') {
      final res = await PartnerVerificationService.verifyVatNumber(identifier);
      if (!mounted) return;
      setState(() {
        _isVerifyingPartner = false;
        _isPartnerVerified = res['success'] == true;
        _partnerVerificationMsg = res['message']?.toString();
      });
      return;
    }

    final heOk = RegExp(r'^(HE)?\s?[0-9]{1,7}$').hasMatch(identifier.toUpperCase().replaceAll(RegExp(r'[\s.-]'), ' ').trim());
    setState(() {
      _isVerifyingPartner = false;
      _isPartnerVerified = heOk;
      _partnerVerificationMsg = heOk
          ? 'A formátum megfelelő. A cégjegyzékszámot (HE) az adminisztrátor ellenőrzi a cégjegyzékben. ✅'
          : 'Érvénytelen formátum (várt: HE + szám, pl. HE 123456). ❌';
    });
  }

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

    if (_isRegisterMode && _isPartnerMode) {
      final regNumber = _partnerIdentifierType == 'HE' ? _licenseController.text.trim() : _taxController.text.trim();
      if (regNumber.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Partnerként a cégjegyzékszám (HE) vagy az adószám (VAT) megadása kötelező! ⚠️'), backgroundColor: Colors.redAccent),
        );
        return;
      }
    }

    if (_isRegisterMode) {
      final result = await AuthState.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Felhasználó',
        asPartner: _isPartnerMode,
      );

      if (result.success && mounted) {
        if (_isPartnerMode && _selectedCategoryKey == 'cat_partner_other' && _customCategoryController.text.trim().isNotEmpty) {
          DataService.addCustomCategory(_customCategoryController.text.trim());
        }

        // Céges partner jelentkezés mentése (adminisztrátori jóváhagyásra vár)
        AuthResult? partnerResult;
        if (_isPartnerMode) {
          partnerResult = await AuthState.submitPartnerApplication(
            companyName: _businessNameController.text.trim(),
            regType: _partnerIdentifierType,
            regNumber: _partnerIdentifierType == 'HE' ? _licenseController.text.trim() : _taxController.text.trim(),
          );
          if (!mounted) return;
        }

        await showVerificationSentDialog(
          context,
          email: _emailController.text.trim(),
          sent: result.verificationEmailSent,
          extraMessage: _isPartnerMode
              ? (partnerResult?.success == true
                  ? 'A partner jelentkezésedet rögzítettük, az automatikus ellenőrzés pár másodpercen belül lefut. Hirdetést a jóváhagyás után adhatsz fel (a profilodon az „Állapot frissítése” gombbal nézheted meg).'
                  : (partnerResult?.message ?? 'A partner jelentkezés mentése nem sikerült.'))
              : null,
        );
        if (!mounted) return;
        setState(() {});
      } else if (!result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Hiba történt a regisztráció során! ⚠️'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      final result = await AuthState.loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sikeres bejelentkezés! ✅'), backgroundColor: Colors.green),
        );
        setState(() {});
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Helytelen e-mail vagy jelszó! ⚠️'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// Hirdetésfeladás: csak jóváhagyott partnernek és adminnak jelenik meg a gomb, mindenki más tájékoztatást kap.
  Widget _buildListingAccess() {
    return AnimatedBuilder(
      animation: Listenable.merge([AuthState.isAdmin, AuthState.partnerStatus, AuthState.partnerNote]),
      builder: (context, _) {
        final isAdmin = AuthState.isAdmin.value;
        final status = AuthState.partnerStatus.value;

        if (isAdmin || status == 'approved') {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sunnyGold,
                      foregroundColor: textDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add_home_work_rounded, size: 18),
                    label: const Text('Új hirdetés feladása', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddListingWizardPage()),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textDark,
                      side: const BorderSide(color: deepBlueIcon, width: 1.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.list_alt_rounded, size: 18),
                    label: const Text('Hirdetéseim', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyListingsPage()),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final String info;
        switch (status) {
          case 'pending':
            info = 'A partner jelentkezésed jóváhagyásra vár. Hirdetést a jóváhagyás után adhatsz fel.';
            break;
          case 'rejected':
            info = 'A partner jelentkezésedet elutasították. Kérdés esetén keresd az ügyfélszolgálatot.';
            break;
          default:
            info = 'Hirdetést csak jóváhagyott céges partner adhat fel.';
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info,
                style: TextStyle(color: textDark.withValues(alpha: 0.85), fontSize: 12.5),
              ),
              if (AuthState.partnerNote.value.isNotEmpty && status != 'none')
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    AuthState.partnerNote.value,
                    style: TextStyle(color: textDark.withValues(alpha: 0.7), fontSize: 11.5, fontStyle: FontStyle.italic),
                  ),
                ),
              if (status == 'pending')
                TextButton.icon(
                  onPressed: () async {
                    await AuthState.refreshRoles();
                    if (mounted) setState(() {});
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Állapot frissítése'),
                ),
            ],
          ),
        );
      },
    );
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
                          _buildListingAccess(),
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
                    if (!_isRegisterMode)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => showForgotPasswordDialog(
                            context,
                            initialEmail: _emailController.text.trim(),
                          ),
                          child: const Text(
                            'Elfelejtett jelszó?',
                            style: TextStyle(color: mintGreenBorder, fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                        ),
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

                      // --- KÉTUTAS PARTNER TÍPUS VÁLASZTÓ (HE vagy VAT) ---
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF093753),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: mintGreenBorder, width: 1.2),
                        ),
                        child: ToggleButtons(
                          isSelected: [_partnerIdentifierType == 'HE', _partnerIdentifierType == 'VAT'],
                          onPressed: (index) {
                            setState(() {
                              _partnerIdentifierType = index == 0 ? 'HE' : 'VAT';
                              _isPartnerVerified = false;
                              _partnerVerificationMsg = null;
                            });
                          },
                          color: Colors.white70,
                          selectedColor: textDark,
                          fillColor: sunnyGold,
                          borderRadius: BorderRadius.circular(12),
                          constraints: const BoxConstraints(minHeight: 38, minWidth: 140),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(AppLanguage.tr('profile_id_type_he'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(AppLanguage.tr('profile_id_type_vat'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Dinamikus mező és ellenőrzés gomb a választás alapján
                      if (_partnerIdentifierType == 'HE') ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _licenseController,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: _inputDec(AppLanguage.tr('profile_license_hint_he'), Icons.badge_outlined),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: sunnyGold,
                                foregroundColor: textDark,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _isVerifyingPartner ? null : _verifyPartnerIdentifier,
                              child: _isVerifyingPartner
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Text(AppLanguage.tr('profile_verify_btn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _taxController,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: _inputDec(AppLanguage.tr('profile_tax_hint_vat'), Icons.receipt_long_outlined),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: sunnyGold,
                                foregroundColor: textDark,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _isVerifyingPartner ? null : _verifyPartnerIdentifier,
                              child: _isVerifyingPartner
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Text(AppLanguage.tr('profile_verify_btn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                      ],

                      // Validációs visszajelzés
                      if (_partnerVerificationMsg != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _partnerVerificationMsg!,
                          style: TextStyle(
                            color: _isPartnerVerified ? mintGreenBorder : Colors.redAccent,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                              activeThumbColor: sunnyGold,
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