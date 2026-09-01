import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/app_language.dart';
import '../../core/services/auth_state.dart';
import '../../core/services/data_service.dart';
import '../../core/services/stripe_service.dart';
import '../../core/widgets/cyvesta_scaffold.dart';
import '../accommodation/presentation/accommodation_detail_page.dart';
import '../accommodation/presentation/accommodation_list_page.dart';
import '../admin/admin_moderation_page.dart';
import '../experiences/experiences_page.dart';
import '../experiences/presentation/experience_detail_page.dart';
import '../faq/faq_page.dart';
import '../gastronomy/gastronomy_page.dart';
import '../gastronomy/presentation/gastronomy_detail_page.dart';
import '../map/map_page.dart';
import '../profile/host_packages_page.dart';
import '../profile/host_registration_page.dart';
import '../transfer/transfer_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  static const int _kInitialPage = 1000;
  late final PageController _pageController;
  Timer? _carouselTimer;
  int _currentCarouselIndex = 0;

  String _selectedRegionFilter = 'all';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _kInitialPage, viewportFraction: 0.92);
    _startAutoCarousel();
  }

  void _startAutoCarousel() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _showAdminLoginDialog(BuildContext context) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF072A40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: mintGreenBorder, width: 1.4),
        ),
        title: const Text('Admin Belépés (Bubu) 🛡️', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Add meg a jelszót (1234)',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF093753),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: mintGreenBorder)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mégse', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: sunnyGold, foregroundColor: textDark),
            onPressed: () {
              if (passwordController.text.trim() == '1234') {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminModerationPage()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hibás admin jelszó! ⚠️', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
                );
              }
            },
            child: const Text('Belépés', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleSocialAuth({
    required BuildContext context,
    required BuildContext modalContext,
    required String provider,
    required bool isRegisterMode,
    required int selectedRole,
    required bool acceptedTerms,
  }) async {
    if (isRegisterMode && !acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A regisztrációhoz el kell fogadni az ÁSZF-et és a GDPR nyilatkozatot! ⚠️')),
      );
      return;
    }

    if (isRegisterMode && selectedRole != 0) {
      final planName = selectedRole == 1 ? 'Éves Partner Tagság' : 'Féléves Partner Tagság';
      final amount = selectedRole == 1 ? '240' : '180';

      final success = await StripeService.makePayment(
        context: context,
        amount: amount,
        currency: 'EUR',
        planName: planName,
      );

      if (success) {
        AuthState.loginWithProvider(provider);
        AuthState.isPartner.value = true;
        if (modalContext.mounted) Navigator.pop(modalContext);
        if (context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HostRegistrationPage()));
        }
      }
    } else {
      AuthState.loginWithProvider(provider);
      Navigator.pop(modalContext);
    }
  }

  void _showAuthModal(BuildContext context) {
    bool isRegisterMode = false;
    int selectedRole = 0; 
    bool acceptedTerms = false;

    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    final taxController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF072A40),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: mintGreenBorder, width: 1.4),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return ValueListenableBuilder<bool>(
            valueListenable: AuthState.isLoggedIn,
            builder: (context, loggedIn, child) {
              if (loggedIn) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(color: Color(0xFF093753), shape: BoxShape.circle),
                        child: const Icon(Icons.person_rounded, color: sunnyGold, size: 48),
                      ),
                      const SizedBox(height: 12),
                      Text(AuthState.userName.value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(AuthState.userEmail.value, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                          icon: const Icon(Icons.logout_rounded),
                          label: Text(AppLanguage.tr('auth_logout_btn'), style: const TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () {
                            AuthState.logout();
                            Navigator.pop(ctx);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 45,
                          height: 4,
                          decoration: BoxDecoration(color: mintGreenBorder.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isRegisterMode ? AppLanguage.tr('auth_register_title') : AppLanguage.tr('auth_login_title'),
                            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white70),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (isRegisterMode) ...[
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setModalState(() => selectedRole = 0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: selectedRole == 0 ? sunnyGold : const Color(0xFF093753),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: selectedRole == 0 ? Colors.white : mintGreenBorder.withValues(alpha: 0.4)),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(AppLanguage.tr('role_guest'), style: TextStyle(color: selectedRole == 0 ? textDark : Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                      Text(AppLanguage.tr('role_free'), style: TextStyle(color: selectedRole == 0 ? textDark : mintGreenBorder, fontWeight: FontWeight.w900, fontSize: 9.5)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setModalState(() => selectedRole = 1),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: selectedRole == 1 ? sunnyGold : const Color(0xFF093753),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: selectedRole == 1 ? Colors.white : mintGreenBorder.withValues(alpha: 0.4)),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(AppLanguage.tr('role_annual'), style: TextStyle(color: selectedRole == 1 ? textDark : Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                      Text(AppLanguage.tr('role_annual_price'), style: TextStyle(color: selectedRole == 1 ? textDark : mintGreenBorder, fontWeight: FontWeight.w900, fontSize: 9.5)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setModalState(() => selectedRole = 2),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: selectedRole == 2 ? sunnyGold : const Color(0xFF093753),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: selectedRole == 2 ? Colors.white : mintGreenBorder.withValues(alpha: 0.4)),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(AppLanguage.tr('role_half_year'), style: TextStyle(color: selectedRole == 2 ? textDark : Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                      Text(AppLanguage.tr('role_half_year_price'), style: TextStyle(color: selectedRole == 2 ? textDark : mintGreenBorder, fontWeight: FontWeight.w900, fontSize: 9.5)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        TextField(
                          controller: nameController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: _authInputDec(selectedRole == 0 ? '${AppLanguage.tr('auth_name_hint')} *' : '${AppLanguage.tr('auth_business_name_hint')} *', Icons.person_outline),
                        ),
                        const SizedBox(height: 10),

                        if (selectedRole != 0) ...[
                          TextField(
                            controller: taxController,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: _authInputDec('${AppLanguage.tr('auth_tax_hint')} *', Icons.badge_outlined),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: addressController,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: _authInputDec('${AppLanguage.tr('auth_address_hint')} *', Icons.location_on_outlined),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: phoneController,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: _authInputDec('${AppLanguage.tr('auth_phone_hint')} *', Icons.phone_outlined),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],

                      TextField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: _authInputDec('${AppLanguage.tr('auth_email_hint')} *', Icons.email_outlined),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: _authInputDec('${AppLanguage.tr('auth_password_hint')} *', Icons.lock_outline),
                      ),
                      const SizedBox(height: 10),

                      if (isRegisterMode) ...[
                        Row(
                          children: [
                            Checkbox(
                              value: acceptedTerms,
                              activeColor: sunnyGold,
                              checkColor: textDark,
                              onChanged: (val) {
                                setModalState(() => acceptedTerms = val ?? false);
                              },
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final url = Uri.parse('https://docs.google.com/document/d/1qE_7YtmwU7baCj8XB7GAzaPhxzS2yGs8yep1synu7zA/edit?usp=drive_web');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  }
                                },
                                child: Text(
                                  '${AppLanguage.tr('terms_acceptance')} *',
                                  style: const TextStyle(
                                    color: mintGreenBorder, 
                                    fontSize: 11, 
                                    height: 1.3,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],

                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: sunnyGold,
                            foregroundColor: textDark,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();
                            final name = nameController.text.trim();

                            if (email.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Az e-mail és a jelszó megadása kötelező! ⚠️')),
                              );
                              return;
                            }

                            if (isRegisterMode) {
                              if (!acceptedTerms) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('A regisztrációhoz el kell fogadni az ÁSZF-et és az Adatvédelmi nyilatkozatot! ⚠️')),
                                );
                                return;
                              }

                              if (selectedRole != 0) {
                                if (taxController.text.trim().isEmpty ||
                                    addressController.text.trim().isEmpty ||
                                    phoneController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Minden partner adat kitöltése kötelező! ⚠️')),
                                  );
                                  return;
                                }

                                final planName = selectedRole == 1 ? 'Éves Partner Tagság' : 'Féléves Partner Tagság';
                                final amount = selectedRole == 1 ? '240' : '180';

                                final successPayment = await StripeService.makePayment(
                                  context: context,
                                  amount: amount,
                                  currency: 'EUR',
                                  planName: planName,
                                );

                                if (!successPayment) return;
                              }

                              final successReg = await AuthState.registerWithEmail(
                                email: email,
                                password: password,
                                name: name.isNotEmpty ? name : email.split('@').first,
                                asPartner: selectedRole != 0,
                              );

                              if (successReg) {
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (selectedRole != 0 && context.mounted) {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HostRegistrationPage()));
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Hiba történt a regisztráció során! Ellenőrizze az adatokat.')),
                                  );
                                }
                              }
                            } else {
                              final successLogin = await AuthState.loginWithEmail(
                                email: email,
                                password: password,
                              );

                              if (successLogin) {
                                if (ctx.mounted) Navigator.pop(ctx);
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Hibás e-mail vagy jelszó!')),
                                  );
                                }
                              }
                            }
                          },
                          child: Text(
                            isRegisterMode
                                ? (selectedRole == 1
                                    ? AppLanguage.tr('btn_stripe_annual')
                                    : (selectedRole == 2
                                        ? AppLanguage.tr('btn_stripe_half')
                                        : AppLanguage.tr('btn_guest_reg')))
                                : AppLanguage.tr('auth_login_btn'),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          const Expanded(child: Divider(color: Colors.white24)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(AppLanguage.tr('auth_or_social'), style: const TextStyle(color: Colors.white60, fontSize: 11)),
                          ),
                          const Expanded(child: Divider(color: Colors.white24)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildSocialBtn('Google', Icons.g_mobiledata_rounded, Colors.redAccent, () {
                              _handleSocialAuth(
                                context: context,
                                modalContext: ctx,
                                provider: 'Google',
                                isRegisterMode: isRegisterMode,
                                selectedRole: selectedRole,
                                acceptedTerms: acceptedTerms,
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSocialBtn('Apple', Icons.apple_rounded, Colors.white, () {
                              _handleSocialAuth(
                                context: context,
                                modalContext: ctx,
                                provider: 'Apple',
                                isRegisterMode: isRegisterMode,
                                selectedRole: selectedRole,
                                acceptedTerms: acceptedTerms,
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSocialBtn('Facebook', Icons.facebook_rounded, Colors.blueAccent, () {
                              _handleSocialAuth(
                                context: context,
                                modalContext: ctx,
                                provider: 'Facebook',
                                isRegisterMode: isRegisterMode,
                                selectedRole: selectedRole,
                                acceptedTerms: acceptedTerms,
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () => setModalState(() => isRegisterMode = !isRegisterMode),
                        child: Text(
                          isRegisterMode ? AppLanguage.tr('auth_switch_to_login') : AppLanguage.tr('auth_switch_to_register'),
                          style: const TextStyle(color: mintGreenBorder, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  InputDecoration _authInputDec(String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF093753),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54, fontSize: 12),
      prefixIcon: Icon(icon, color: sunnyGold, size: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: mintGreenBorder, width: 1)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: mintGreenBorder.withValues(alpha: 0.5), width: 1)),
    );
  }

  Widget _buildSocialBtn(String label, IconData icon, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF093753),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: mintGreenBorder.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showPropertyTypeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF072A40),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: mintGreenBorder, width: 1.4),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 45,
                height: 4,
                decoration: BoxDecoration(color: mintGreenBorder.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLanguage.tr('choose_property_type'), style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
                IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white70), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(color: Colors.white12, height: 12),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => AccommodationListPage(filterType: 'rent', pageTitle: AppLanguage.tr('rent_apartments'))));
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: turquoiseGlass, borderRadius: BorderRadius.circular(16), border: Border.all(color: mintGreenBorder, width: 1.4)),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: deepBlueIcon, shape: BoxShape.circle), child: const Icon(Icons.beach_access_rounded, color: sunnyGold, size: 24)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLanguage.tr('rent_apartments'), style: const TextStyle(color: textDark, fontSize: 14.5, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 2),
                          Text(AppLanguage.tr('rent_apartments_desc'), style: TextStyle(color: textDark.withValues(alpha: 0.85), fontSize: 11.5)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: textDark, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => AccommodationListPage(filterType: 'sale', pageTitle: AppLanguage.tr('sale_properties'))));
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF093753), borderRadius: BorderRadius.circular(16), border: Border.all(color: sunnyGold, width: 1.4)),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: deepBlueIcon, shape: BoxShape.circle), child: const Icon(Icons.key_rounded, color: sunnyGold, size: 24)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLanguage.tr('sale_properties'), style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 2),
                          Text(AppLanguage.tr('sale_properties_desc'), style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: mintGreenBorder, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showNearbyServicesModal(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {'title': AppLanguage.tr('serv_car_rental'), 'desc': AppLanguage.tr('serv_car_rental_desc'), 'icon': Icons.directions_car_rounded, 'color': sunnyGold},
      {'title': AppLanguage.tr('serv_bike_rental'), 'desc': AppLanguage.tr('serv_bike_rental_desc'), 'icon': Icons.two_wheeler_rounded, 'color': mintGreenBorder},
      {'title': AppLanguage.tr('serv_pharmacy'), 'desc': AppLanguage.tr('serv_pharmacy_desc'), 'icon': Icons.local_pharmacy_rounded, 'color': Colors.redAccent},
      {'title': AppLanguage.tr('serv_supermarket'), 'desc': AppLanguage.tr('serv_supermarket_desc'), 'icon': Icons.shopping_cart_rounded, 'color': Colors.lightBlueAccent},
      {'title': AppLanguage.tr('serv_nightlife'), 'desc': AppLanguage.tr('serv_nightlife_desc'), 'icon': Icons.nightlife_rounded, 'color': Colors.pinkAccent},
      {'title': AppLanguage.tr('serv_bus_stop'), 'desc': AppLanguage.tr('serv_bus_stop_desc'), 'icon': Icons.directions_bus_rounded, 'color': Colors.amberAccent},
      {'title': AppLanguage.tr('serv_atm'), 'desc': AppLanguage.tr('serv_atm_desc'), 'icon': Icons.atm_rounded, 'color': Colors.tealAccent},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF072A40),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: mintGreenBorder, width: 1.4),
      ),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 45,
                height: 4,
                decoration: BoxDecoration(color: mintGreenBorder.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLanguage.tr('nearby_services_title'), style: const TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w900)),
                IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white70), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(color: Colors.white12, height: 10),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final s = services[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF093753),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: mintGreenBorder.withValues(alpha: 0.3)),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: deepBlueIcon, shape: BoxShape.circle, border: Border.all(color: s['color'] as Color, width: 1.2)),
                        child: Icon(s['icon'] as IconData, color: s['color'] as Color, size: 20),
                      ),
                      title: Text(s['title'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text(s['desc'] as String, style: const TextStyle(color: Colors.white60, fontSize: 11)),
                      trailing: const Icon(Icons.map_rounded, color: mintGreenBorder, size: 18),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MapPage()));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF072A40),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLanguage.tr('lang_title'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            _buildLangOption('🇭🇺 Magyar', 'hu', ctx),
            _buildLangOption('🇬🇧 English', 'en', ctx),
            _buildLangOption('🇬🇷 Ελληνικά', 'el', ctx),
            _buildLangOption('🇩🇪 Deutsch', 'de', ctx),
            _buildLangOption('🇷🇺 Русский', 'ru', ctx),
          ],
        ),
      ),
    );
  }

  Widget _buildLangOption(String label, String code, BuildContext ctx) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      trailing: AppLanguage.currentLocale.value == code ? const Icon(Icons.check_circle, color: mintGreenBorder) : null,
      onTap: () {
        AppLanguage.setLanguage(code);
        Navigator.pop(ctx);
      },
    );
  }

  void _navigateToDetail(BuildContext context, Map<String, dynamic> item) {
    final title = item['title']?.toString().toLowerCase() ?? '';
    final category = item['category']?.toString().toLowerCase() ?? '';

    if (category == 'experience' || title.contains('cruise') || title.contains('yacht')) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ExperienceDetailPage(itemData: item)));
      return;
    }
    if (category == 'gastronomy' || title.contains('steak') || title.contains('bakery') || title.contains('breeze')) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => GastronomyDetailPage(itemData: item)));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => AccommodationDetailPage(accommodationData: item)));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        return CyvestaScaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logowhite.png',
                        height: 48,
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Text('CYVESTA', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onLongPress: () => _showAdminLoginDialog(context),
                            child: IconButton(
                              icon: const Icon(Icons.info_outline_rounded, color: sunnyGold, size: 23),
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqPage())),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.language_rounded, color: mintGreenBorder, size: 23),
                            onPressed: () => _showLanguageSelector(context),
                          ),
                          IconButton(
                            icon: const Icon(Icons.diamond_rounded, color: sunnyGold, size: 23),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HostPackagesPage())),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  Text(
                    AppLanguage.tr('slogan'),
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF093753),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: mintGreenBorder, width: 1.4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedRegionFilter,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF072A40),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 24),
                        items: [
                          DropdownMenuItem<String>(
                            value: 'all',
                            child: Text(
                              AppLanguage.tr('search_region_hint'),
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                          DropdownMenuItem<String>(
                            value: 'paphos',
                            child: Text('Paphos & Coral Bay 🏖️', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                          DropdownMenuItem<String>(
                            value: 'kyrenia',
                            child: Text('Kyrenia (Girne) 🏰', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                          DropdownMenuItem<String>(
                            value: 'limassol',
                            child: Text('Limassol & Akrotiri 🌴', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                          DropdownMenuItem<String>(
                            value: 'larnaca',
                            child: Text('Larnaca & Ayia Napa ⛵', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                          DropdownMenuItem<String>(
                            value: 'famagusta',
                            child: Text('Famagusta & Long Beach 🌊', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                        ],
                        onChanged: (val) => setState(() => _selectedRegionFilter = val ?? 'all'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: _buildCategorySquare(AppLanguage.tr('cat_accommodations'), Icons.apartment_rounded, () => _showPropertyTypeModal(context))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildCategorySquare(AppLanguage.tr('cat_experiences'), Icons.sailing_rounded, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExperiencesPage())))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildCategorySquare(AppLanguage.tr('cat_gastronomy'), Icons.restaurant_rounded, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GastronomyPage())))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildCategorySquare(AppLanguage.tr('cat_transfer'), Icons.directions_car_rounded, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferPage())))),
                    ],
                  ),
                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () => _showNearbyServicesModal(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: turquoiseGlass, borderRadius: BorderRadius.circular(14), border: Border.all(color: mintGreenBorder, width: 1.2)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.near_me_rounded, color: textDark, size: 18),
                              const SizedBox(width: 8),
                              Text(AppLanguage.tr('nearby_search_bar'), style: const TextStyle(color: textDark, fontSize: 11.5, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Icon(Icons.tune_rounded, color: textDark, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: DataService.accommodations,
                    builder: (context, allItems, child) {
                      final items = allItems.where((i) => i['status'] != 'rejected').toList();
                      if (items.isEmpty) return const SizedBox();

                      return Column(
                        children: [
                          SizedBox(
                            height: 330,
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: (idx) => setState(() => _currentCarouselIndex = idx % items.length),
                              itemBuilder: (context, index) {
                                final item = items[index % items.length];
                                final title = item['title']?.toString() ?? '';
                                final location = item['location']?.toString() ?? '';
                                final price = item['price']?.toString() ?? '';
                                final rating = item['rating']?.toString() ?? '4.95';
                                final imagePath = item['imagePath']?.toString() ?? 'assets/images/szarvas.png';

                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: turquoiseGlass,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(color: mintGreenBorder, width: 1.6),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            Image.asset(
                                              imagePath,
                                              height: 210,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) => Container(height: 210, color: deepBlueIcon, child: const Icon(Icons.villa_rounded, size: 60, color: mintGreenBorder)),
                                            ),
                                            
                                            Positioned(
                                              top: 10,
                                              right: 10,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.yellow,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  AppLanguage.tr('featured_badge'),
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            Positioned(
                                              top: 10,
                                              left: 10,
                                              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                                                valueListenable: DataService.favoriteItems,
                                                builder: (context, favs, child) {
                                                  final isFav = DataService.isFavorite(item);
                                                  return GestureDetector(
                                                    onTap: () => DataService.toggleFavorite(item),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(7),
                                                      decoration: const BoxDecoration(color: deepBlueIcon, shape: BoxShape.circle),
                                                      child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.redAccent : Colors.white, size: 18),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            if (price.isNotEmpty)
                                              Positioned(
                                                bottom: 10,
                                                left: 10,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(color: deepBlueIcon, borderRadius: BorderRadius.circular(8)),
                                                  child: Text(price, style: const TextStyle(color: sunnyGold, fontSize: 12, fontWeight: FontWeight.w900)),
                                                ),
                                              ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(child: Text(title, style: const TextStyle(color: textDark, fontSize: 13.5, fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.star, color: sunnyGold, size: 14),
                                                      const SizedBox(width: 3),
                                                      Text(rating, style: const TextStyle(color: textDark, fontSize: 11.5, fontWeight: FontWeight.bold)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(location, style: TextStyle(color: textDark.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w600)),
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                width: double.infinity,
                                                height: 36,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: deepBlueIcon, foregroundColor: Colors.white),
                                                  onPressed: () => _navigateToDetail(context, item),
                                                  child: Text(AppLanguage.tr('view_details'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(items.length, (i) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: _currentCarouselIndex == i ? 18 : 6,
                              height: 6,
                              decoration: BoxDecoration(color: _currentCarouselIndex == i ? sunnyGold : mintGreenBorder.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(3)),
                            )),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  ValueListenableBuilder<bool>(
                    valueListenable: AuthState.isLoggedIn,
                    builder: (context, loggedIn, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: loggedIn ? const Color(0xFF093753) : sunnyGold,
                            foregroundColor: loggedIn ? Colors.white : textDark,
                            side: BorderSide(color: loggedIn ? mintGreenBorder : Colors.transparent, width: 1.4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: Icon(loggedIn ? Icons.verified_user_rounded : Icons.account_circle_rounded, size: 22, color: loggedIn ? mintGreenBorder : textDark),
                          label: Text(
                            loggedIn ? '${AppLanguage.tr('auth_logged_in_as')} ${AuthState.userName.value}' : AppLanguage.tr('auth_btn_main'),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                          ),
                          onPressed: () => _showAuthModal(context),
                        ),
                      );
                    },
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

  Widget _buildCategorySquare(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: turquoiseGlass,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: mintGreenBorder, width: 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textDark, size: 22),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: textDark, fontSize: 9.5, fontWeight: FontWeight.w900, height: 1.1),
            ),
          ],
        ),
      ),
    );
  }
}