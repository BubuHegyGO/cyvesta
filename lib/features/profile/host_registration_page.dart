import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/widgets/cyvesta_scaffold.dart';
import '../accommodation/presentation/steps/add_listing_wizard_page.dart';

class HostRegistrationPage extends StatelessWidget {
  const HostRegistrationPage({super.key});

  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        return CyvestaScaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      const Text(
                        'Partner Regisztráció 💎',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Kezdd el az 5 lépéses hirdetésfeladást, tölts fel fotókat, iCal naptárat és add meg a WhatsApp elérhetőséged!',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sunnyGold,
                        foregroundColor: const Color(0xFF0F172A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const AddListingWizardPage()),
                        );
                      },
                      child: const Text(
                        'Ugrás az 5 lépéses Varázslóra 🚀',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}