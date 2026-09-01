import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/services/data_service.dart';
import '../../../core/widgets/cyvesta_scaffold.dart';

class GastronomyDetailPage extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const GastronomyDetailPage({super.key, required this.itemData});

  static const Color darkBg = Color(0xFF061822);
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  Future<void> _launchWhatsApp(String phone, String title) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final msg = Uri.encodeComponent("Hello! I would like to reserve a table at $title via CYVESTA App.");
    final uri = Uri.parse("https://wa.me/$cleanPhone?text=$msg");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = itemData['title']?.toString() ?? 'Restaurant';
    final location = itemData['location']?.toString() ?? 'Cyprus';
    final rating = itemData['rating']?.toString() ?? '4.95';
    final imagePath = itemData['imagePath']?.toString() ?? 'assets/images/etterem.png';
    final desc = itemData['description']?.toString() ?? 'Kiváló minőségű ételek és hangulatos atmoszféra.';
    final hours = itemData['openingHours']?.toString() ?? '11:00 - 23:00';
    final phone = itemData['phone']?.toString() ?? '+35799112233';
    final tags = (itemData['tags'] as List<String>?) ?? ['Specialty Food', 'Outdoor Seating', 'Wi-Fi'];

    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        return CyvestaScaffold(
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    backgroundColor: darkBg,
                    leading: CircleAvatar(
                      backgroundColor: deepBlueIcon.withValues(alpha: 0.8),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: mintGreenBorder, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    actions: [
                      ValueListenableBuilder<List<Map<String, dynamic>>>(
                        valueListenable: DataService.favoriteItems,
                        builder: (context, favs, child) {
                          final isFav = DataService.isFavorite(itemData);
                          return CircleAvatar(
                            backgroundColor: deepBlueIcon.withValues(alpha: 0.8),
                            child: IconButton(
                              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.redAccent : Colors.white, size: 20),
                              onPressed: () => DataService.toggleFavorite(itemData),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(color: deepBlueIcon),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cím kártya
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: turquoiseGlass,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: mintGreenBorder, width: 1.4),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(title, style: const TextStyle(color: textDark, fontSize: 16.5, fontWeight: FontWeight.w900)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: deepBlueIcon, borderRadius: BorderRadius.circular(8)),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star, color: sunnyGold, size: 14),
                                          const SizedBox(width: 4),
                                          Text(rating, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, color: deepBlueIcon, size: 16),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text(location, style: TextStyle(color: textDark.withValues(alpha: 0.85), fontSize: 12, fontWeight: FontWeight.w700))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Kapcsolat gombok (WhatsApp Asztalfoglalás + Közvetlen Hívás)
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF25D366),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  icon: const Icon(Icons.chat_rounded, size: 18),
                                  label: Text(AppLanguage.tr('btn_table_reservation'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                  onPressed: () => _launchWhatsApp(phone, title),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: deepBlueIcon,
                                    foregroundColor: mintGreenBorder,
                                    side: const BorderSide(color: mintGreenBorder, width: 1.2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                                  label: Text(AppLanguage.tr('btn_call_restaurant'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                  onPressed: () => _makePhoneCall(phone),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Nyitvatartás doboz
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: deepBlueIcon,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: mintGreenBorder.withValues(alpha: 0.6)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_filled_rounded, color: sunnyGold, size: 22),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(AppLanguage.tr('label_opening_hours'), style: const TextStyle(color: Colors.white60, fontSize: 11)),
                                    Text(hours, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Leírás & Címkék
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: deepBlueIcon,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: mintGreenBorder.withValues(alpha: 0.6)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLanguage.tr('label_menu_preview'), style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: tags.map((t) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF093753),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: mintGreenBorder.withValues(alpha: 0.4)),
                                    ),
                                    child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                  )).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}