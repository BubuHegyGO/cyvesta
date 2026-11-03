import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/widgets/cyvesta_scaffold.dart';
import 'host_registration_page.dart';

class HostPackagesPage extends StatelessWidget {
  const HostPackagesPage({super.key});

  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  @override
  Widget build(BuildContext context) {
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
                  // Felső sáv visszalépő gombbal
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
                      Expanded(
                        child: Text(
                          AppLanguage.tr('reg_page_title'),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Fő kiemelő kártya (0% Jutalék & Ingyenesség)
                  Container(
                    padding: const EdgeInsets.all(18),
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
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(color: deepBlueIcon, shape: BoxShape.circle),
                              child: const Icon(Icons.verified_rounded, color: sunnyGold, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                AppLanguage.tr('reg_free_title'),
                                style: const TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppLanguage.tr('reg_free_desc'),
                          style: TextStyle(color: textDark.withValues(alpha: 0.85), fontSize: 12.5, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // PARTNER SZEKCIÓ
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF093753),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sunnyGold, width: 1.4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.business_center_rounded, color: sunnyGold, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              AppLanguage.tr('reg_partner_section_title'),
                              style: const TextStyle(color: sunnyGold, fontSize: 15, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLanguage.tr('reg_partner_section_desc'),
                          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // VENDÉG SZEKCIÓ
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF093753),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: mintGreenBorder, width: 1.4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.travel_explore_rounded, color: mintGreenBorder, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              AppLanguage.tr('reg_guest_section_title'),
                              style: const TextStyle(color: mintGreenBorder, fontSize: 15, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLanguage.tr('reg_guest_section_desc'),
                          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Navigációs gomb a regisztrációs oldalra
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sunnyGold,
                        foregroundColor: textDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(
                        AppLanguage.tr('reg_proceed_btn'),
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HostRegistrationPage()),
                        );
                      },
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
}