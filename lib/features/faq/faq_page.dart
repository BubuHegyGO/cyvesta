import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/app_language.dart';
import '../../core/widgets/cyvesta_scaffold.dart';
import '../profile/host_packages_page.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  final List<Map<String, dynamic>> _faqItems = [
    {
      'icon': Icons.rocket_launch_rounded,
      'q': 'faq_q1',
      'a': 'faq_a1',
    },
    {
      'icon': Icons.bolt_rounded,
      'q': 'faq_q2',
      'a': 'faq_a2',
    },
    {
      'icon': Icons.savings_rounded,
      'q': 'faq_q3',
      'a': 'faq_a3',
    },
    {
      'icon': Icons.person_pin_circle_rounded,
      'q': 'faq_q4',
      'a': 'faq_a4',
    },
    {
      'icon': Icons.diamond_rounded,
      'q': 'faq_q5',
      'a': 'faq_a5',
    },
    {
      'icon': Icons.sync_rounded,
      'q': 'faq_q6',
      'a': 'faq_a6',
    },
    {
      'icon': Icons.gavel_rounded,
      'q': 'faq_q7',
      'a': 'faq_a7',
    },
  ];

  Future<void> _launchDocUrl() async {
    final url = Uri.parse('https://docs.google.com/document/d/1qE_7YtmwU7baCj8XB7GAzaPhxzS2yGs8yep1synu7zA/edit?usp=drive_web');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        return CyvestaScaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      Expanded(
                        child: Text(
                          AppLanguage.tr('faq_page_title'),
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: turquoiseGlass,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: mintGreenBorder, width: 1.4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: deepBlueIcon, shape: BoxShape.circle),
                              child: const Icon(Icons.auto_awesome_rounded, color: sunnyGold, size: 22),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppLanguage.tr('faq_header_title'),
                                style: const TextStyle(color: textDark, fontSize: 14.5, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLanguage.tr('faq_header_desc'),
                          style: TextStyle(color: textDark.withValues(alpha: 0.85), fontSize: 12, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  ..._faqItems.map((faq) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF093753),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: mintGreenBorder.withValues(alpha: 0.4)),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: deepBlueIcon, shape: BoxShape.circle),
                          child: Icon(faq['icon'] as IconData, color: sunnyGold, size: 20),
                        ),
                        iconColor: sunnyGold,
                        collapsedIconColor: mintGreenBorder,
                        title: Text(
                          AppLanguage.tr(faq['q'] as String),
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, height: 1.25),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14, top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLanguage.tr(faq['a'] as String),
                                  style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.45),
                                ),
                                if (faq == _faqItems.last) ...[
                                  const SizedBox(height: 10),
                                  InkWell(
                                    onTap: _launchDocUrl,
                                    child: Text(
                                      AppLanguage.tr('faq_doc_link'),
                                      style: const TextStyle(
                                        color: mintGreenBorder,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: deepBlueIcon,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: sunnyGold, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppLanguage.tr('faq_footer_title'),
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLanguage.tr('faq_footer_desc'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: sunnyGold,
                              foregroundColor: textDark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const HostPackagesPage()),
                              );
                            },
                            child: Text(
                              AppLanguage.tr('faq_footer_btn'),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
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