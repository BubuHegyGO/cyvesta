import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/services/data_service.dart';
import '../../core/widgets/cyvesta_scaffold.dart';
import 'presentation/experience_detail_page.dart';

class ExperiencesPage extends StatelessWidget {
  const ExperiencesPage({super.key});

  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  final List<Map<String, dynamic>> _defaultExperiences = const [
    {
      'id': 'exp_yacht',
      'category': 'experience',
      'title': 'BLUE LAGOON VIP CRUISE ⛵',
      'location': 'Latchi Harbor & Akamas Marina',
      'price': '€45 / fő',
      'rating': '4.98',
      'badge': 'TOP CRUISE',
      'imagePath': 'assets/images/yacht.png',
      'phone': '+35799123456',
      'whatsapp': '+35799123456',
      'description': 'Exkluzív jachtkirándulás a Kék Lagúnához, fürdőzéssel, sznorkelezéssel és ciprusi büféebéddel a fedélzeten.',
    },
    {
      'id': 'exp_safari',
      'category': 'experience',
      'title': 'AKAMAS JEEP & BOAT SAFARI 🚙⛵',
      'location': 'Paphos & Akamas Nemzeti Park',
      'price': '€55 / fő',
      'rating': '4.95',
      'badge': 'ADVENTURE',
      'imagePath': 'assets/images/yacht.png',
      'phone': '+35799654321',
      'whatsapp': '+35799654321',
      'description': 'Egész napos 4x4 terepjáró és hajós szafari az Akamas-félsziget vadregényes tájain.',
    },
    {
      'id': 'exp_sunset',
      'category': 'experience',
      'title': 'PAPHOS SUNSET CATAMARAN 🌅',
      'location': 'Paphos Harbour Promenade',
      'price': '€38 / fő',
      'rating': '4.92',
      'badge': 'SUNSET TRIP',
      'imagePath': 'assets/images/yacht.png',
      'phone': '+35799778899',
      'whatsapp': '+35799778899',
      'description': 'Romantikus naplemente túra koktélokkal, élőzenével és fürdéssel a nyílt tengeren.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        final pageTitle = locale == 'hu'
            ? 'Élmények & Túrák ⛵'
            : (locale == 'el' ? 'Εμπειρίες & Εκδρομές ⛵' : (locale == 'de' ? 'Erlebnisse & Touren ⛵' : (locale == 'ru' ? 'Впечатления и Туры ⛵' : 'Experiences & Tours ⛵')));

        final btnText = locale == 'hu'
            ? 'Részletek & Jelentkezés ⛵'
            : (locale == 'el' ? 'Λεπτομέρειες & Συμμετοχή ⛵' : (locale == 'de' ? 'Details & Buchung ⛵' : (locale == 'ru' ? 'Подробнее и запись ⛵' : 'Details & Booking ⛵')));

        return CyvestaScaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fejléc
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
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
                          pageTitle,
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _defaultExperiences.length,
                    itemBuilder: (context, index) {
                      final item = _defaultExperiences[index];
                      final title = item['title']?.toString() ?? '';
                      final location = item['location']?.toString() ?? '';
                      final rating = item['rating']?.toString() ?? '4.95';
                      final price = item['price']?.toString() ?? '';
                      final imagePath = item['imagePath']?.toString() ?? 'assets/images/yacht.png';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: turquoiseGlass,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: mintGreenBorder, width: 1.4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Image.asset(
                                    imagePath,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(height: 180, color: deepBlueIcon, child: const Icon(Icons.sailing_rounded, color: mintGreenBorder, size: 40)),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: deepBlueIcon, borderRadius: BorderRadius.circular(8)),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.star, color: sunnyGold, size: 14),
                                              const SizedBox(width: 4),
                                              Text(rating, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        ValueListenableBuilder<List<Map<String, dynamic>>>(
                                          valueListenable: DataService.favoriteItems,
                                          builder: (context, favs, child) {
                                            final isFav = DataService.isFavorite(item);
                                            return GestureDetector(
                                              onTap: () => DataService.toggleFavorite(item),
                                              child: Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: const BoxDecoration(color: deepBlueIcon, shape: BoxShape.circle),
                                                child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.redAccent : Colors.white, size: 16),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
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
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, style: const TextStyle(color: textDark, fontSize: 14.5, fontWeight: FontWeight.w900)),
                                    const SizedBox(height: 3),
                                    Text(location, style: TextStyle(color: textDark.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 38,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: deepBlueIcon, foregroundColor: Colors.white),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => ExperienceDetailPage(itemData: item)),
                                          );
                                        },
                                        child: Text(
                                          btnText,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
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
              ],
            ),
          ),
        );
      },
    );
  }
}