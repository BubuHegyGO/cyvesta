import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/services/data_service.dart';
import '../../core/widgets/cyvesta_scaffold.dart';
import 'presentation/gastronomy_detail_page.dart';

class GastronomyPage extends StatelessWidget {
  const GastronomyPage({super.key});

  static const Color darkBg = Color(0xFF061822);
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  final List<Map<String, dynamic>> _defaultGastronomy = const [
    {
      'id': 'rest_steak',
      'category': 'gastronomy',
      'title': 'CASTLE VIEW STEAKHOUSE 🥩',
      'location': 'Kyrenia Castle Promenade, Kyrenia',
      'price': '€32 / person',
      'rating': '4.97',
      'badge': 'PREMIUM STEAK',
      'imagePath': 'assets/images/etterem.png',
      'phone': '+35799112233',
      'website': 'https://cyvesta.com',
      'openingHours': '12:00 - 23:30',
      'description': 'Prémium tengerparti grillétterem és steakhouse lélegzetelállító kilátással a kivilágított várra.',
      'tags': ['Steakhouse', 'Grill', 'Cocktails', 'Sea View'],
    },
    {
      'id': 'bakery_palm',
      'category': 'gastronomy',
      'title': 'THE PALM ARTISAN BAKERY 🥐',
      'location': 'Coral Bay Beachfront, Paphos',
      'price': '€4.50-tól',
      'rating': '4.95',
      'badge': 'COFFEE & BAKERY',
      'imagePath': 'assets/images/cukraszda.png',
      'phone': '+35799445566',
      'website': 'https://cyvesta.com',
      'openingHours': '07:30 - 20:00',
      'description': 'Kézműves pékáruk, frissen sült vajas croissant-ok és specialty kávék közvetlenül a tengerparton.',
      'tags': ['Artisan Bakery', 'Specialty Coffee', 'Breakfast', 'Pastries'],
    },
    {
      'id': 'taverna_breeze',
      'category': 'gastronomy',
      'title': 'KYRENIA HARBOUR BREEZE 🐟',
      'location': 'Kyrenia Old Harbour, Kyrenia',
      'price': '€24 / person',
      'rating': '4.93',
      'badge': 'SEAFOOD & MEZE',
      'imagePath': 'assets/images/csarda.png',
      'phone': '+35799778899',
      'website': 'https://cyvesta.com',
      'openingHours': '11:30 - 23:00',
      'description': 'Mediterrán kikötői taverna autentikus friss halételekkel és meze tálakkal.',
      'tags': ['Fresh Seafood', 'Cyprus Meze', 'Harbour View', 'Wine Bar'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        return CyvestaScaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fejléc vissza gombbal és lefordított címmel
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
                          AppLanguage.tr('dining_spots'),
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
                    itemCount: _defaultGastronomy.length,
                    itemBuilder: (context, index) {
                      final item = _defaultGastronomy[index];
                      final title = item['title']?.toString() ?? '';
                      final location = item['location']?.toString() ?? '';
                      final rating = item['rating']?.toString() ?? '4.95';
                      final imagePath = item['imagePath']?.toString() ?? 'assets/images/etterem.png';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: turquoiseGlass,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: mintGreenBorder, width: 1.4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14.5),
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
                                    errorBuilder: (c, e, s) => Container(height: 180, color: deepBlueIcon, child: const Icon(Icons.restaurant, color: mintGreenBorder, size: 40)),
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
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, style: const TextStyle(color: textDark, fontSize: 14, fontWeight: FontWeight.w900)),
                                    const SizedBox(height: 3),
                                    Text(location, style: TextStyle(color: textDark.withValues(alpha: 0.8), fontSize: 11.5, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 38,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: deepBlueIcon, foregroundColor: Colors.white),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => GastronomyDetailPage(itemData: item)),
                                          );
                                        },
                                        child: Text(
                                          AppLanguage.tr('book_table_btn'),
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