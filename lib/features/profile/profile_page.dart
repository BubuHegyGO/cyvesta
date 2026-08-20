import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/services/auth_state.dart';
import '../../core/widgets/cyvesta_scaffold.dart';
import '../accommodation/presentation/steps/add_listing_wizard_page.dart';
import '../faq/faq_page.dart';
import 'admin_dashboard_page.dart';
import 'edit_profile_page.dart';
import 'host_packages_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

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

  // Hirdetésfeladás gomb kezelése (Partner ellenőrzéssel & Stripe-pal)
  void _handleHostRegistrationTap(BuildContext context) {
    if (AuthState.isPartner.value) {
      // Ha már partner, közvetlenül az 5 lépéses varázsló indul
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddListingWizardPage()));
    } else {
      // Ha még nem partner, először a Stripe fizetési csomagok oldal ugrik fel
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HostPackagesPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        final isEn = locale != 'hu';

        return CyvestaScaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FEJLÉC
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLanguage.tr('profile_title'),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      IconButton(
                        icon: const Icon(Icons.language_rounded, color: mintGreenBorder, size: 22),
                        onPressed: () => _showLanguageSelector(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // FELHASZNÁLÓI KÁRTYA
                  ValueListenableBuilder<bool>(
                    valueListenable: AuthState.isLoggedIn,
                    builder: (context, loggedIn, child) {
                      final name = loggedIn ? AuthState.userName.value : 'CYVESTA Partner & Admin';
                      final email = loggedIn ? AuthState.userEmail.value : 'admin@cyvesta.com';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: turquoiseGlass,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: mintGreenBorder, width: 1.4),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: deepBlueIcon,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person_rounded, color: sunnyGold, size: 30),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(color: textDark, fontSize: 15, fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    email,
                                    style: TextStyle(color: textDark.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: deepBlueIcon,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      AppLanguage.tr('admin_badge'),
                                      style: const TextStyle(color: mintGreenBorder, fontSize: 9.5, fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 1. GYAKORI KÉRDÉSEK & HOGYAN MŰKÖDIK?
                  _buildMenuCard(
                    icon: Icons.help_outline_rounded,
                    iconColor: sunnyGold,
                    title: isEn ? 'How CYVESTA Works (FAQ) 💡' : 'Gyakori Kérdések & Működés 💡',
                    subtitle: isEn ? 'Why CYVESTA is better than regular websites & portals' : 'Miben különbözik egy átlagos weboldaltól és portáltól?',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqPage())),
                  ),
                  const SizedBox(height: 10),

                  // 2. ADMIN MODERÁCIÓS KÖZPONT
                  _buildMenuCard(
                    icon: Icons.shield_rounded,
                    iconColor: mintGreenBorder,
                    title: AppLanguage.tr('admin_center'),
                    subtitle: AppLanguage.tr('admin_center_desc'),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardPage())),
                  ),
                  const SizedBox(height: 10),

                  // 3. HIRDETÉSFELADÁS & PARTNERREGISZTRÁCIÓ (STRIPE + 5 LÉPÉSES VARÁZSLÓ)
                  _buildMenuCard(
                    icon: Icons.add_business_rounded,
                    iconColor: Colors.lightBlueAccent,
                    title: AppLanguage.tr('host_reg'),
                    subtitle: AppLanguage.tr('host_reg_desc'),
                    onTap: () => _handleHostRegistrationTap(context),
                  ),
                  const SizedBox(height: 10),

                  // 4. HIRDETŐI TAGSÁGOK & STRIPE CSOMAGOK
                  _buildMenuCard(
                    icon: Icons.diamond_rounded,
                    iconColor: sunnyGold,
                    title: AppLanguage.tr('host_packages'),
                    subtitle: AppLanguage.tr('host_packages_desc'),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HostPackagesPage())),
                  ),
                  const SizedBox(height: 10),

                  // 5. PROFIL SZERKESZTÉSE
                  _buildMenuCard(
                    icon: Icons.edit_note_rounded,
                    iconColor: Colors.tealAccent,
                    title: AppLanguage.tr('edit_profile'),
                    subtitle: AppLanguage.tr('edit_profile_desc'),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())),
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

  Widget _buildMenuCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF093753),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mintGreenBorder.withValues(alpha: 0.35)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: deepBlueIcon,
            shape: BoxShape.circle,
            border: Border.all(color: iconColor, width: 1.2),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: mintGreenBorder, size: 16),
        onTap: onTap,
      ),
    );
  }
}