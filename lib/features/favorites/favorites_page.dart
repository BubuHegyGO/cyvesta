import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/services/data_service.dart';
import '../../core/widgets/cyvesta_scaffold.dart';
import '../accommodation/presentation/accommodation_detail_page.dart';
import '../experiences/presentation/experience_detail_page.dart';
import '../gastronomy/presentation/gastronomy_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  static const Color darkBg = Color(0xFF061822);
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

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
        final isEn = locale != 'hu';

        final titleText = locale == 'hu'
            ? 'Mentett Kedvencek ❤️'
            : (locale == 'el'
                ? 'Αγαπημένα ❤️'
                : (locale == 'de' ? 'Gespeicherte Favoriten ❤️' : (locale == 'ru' ? 'Избранное ❤️' : 'Saved Favorites ❤️')));

        final emptyTitle = locale == 'hu'
            ? 'Még nincsenek mentett kedvenceid!'
            : (locale == 'el'
                ? 'Δεν υπάρχουν αγαπημένα ακόμα!'
                : (locale == 'de' ? 'Noch keine Favoriten gespeichert!' : (locale == 'ru' ? 'У вас пока нет избранного!' : 'No saved favorites yet!')));

        final emptySubtitle = locale == 'hu'
            ? 'Kattints a szív ikonra a kártyák jobb felső sarkában, és a mentett villák, túrák és éttermek itt fognak megjelenni.'
            : (locale == 'el'
                ? 'Πατήστε το εικονίδιο καρδιάς για να αποθηκεύσετε βίλες, εκδρομές και εστιατόρια εδώ.'
                : (locale == 'de'
                    ? 'Klicke auf das Herz-Symbol, um Villen, Touren und Restaurants hier zu speichern.'
                    : (locale == 'ru'
                        ? 'Нажмите на иконку сердца, чтобы сохранить виллы, туры и рестораны.'
                        : 'Tap the heart icon on cards to save your favorite villas, tours, and restaurants here.')));

        final viewText = locale == 'hu'
            ? 'Megtekintés'
            : (locale == 'el' ? 'Προβολή' : (locale == 'de' ? 'Ansehen' : (locale == 'ru' ? 'Подробнее' : 'View Details')));

        return CyvestaScaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        titleText,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: DataService.favoriteItems,
                    builder: (context, favorites, child) {
                      if (favorites.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: deepBlueIcon,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: mintGreenBorder.withValues(alpha: 0.6), width: 1.5),
                                  ),
                                  child: const Icon(Icons.favorite_border_rounded, color: sunnyGold, size: 40),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  emptyTitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  emptySubtitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final item = favorites[index];
                          final title = item['title']?.toString() ?? 'CYVESTA';
                          final location = item['location']?.toString() ?? 'Cyprus';
                          final price = item['price']?.toString() ?? '';
                          final rating = item['rating']?.toString() ?? '4.95';
                          final imagePath = item['imagePath']?.toString() ?? 'assets/images/szarvas.png';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: turquoiseGlass,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: mintGreenBorder, width: 1.4),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(10),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  imagePath,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    width: 70,
                                    height: 70,
                                    color: deepBlueIcon,
                                    child: const Icon(Icons.villa_rounded, color: mintGreenBorder),
                                  ),
                                ),
                              ),
                              title: Text(
                                title,
                                style: const TextStyle(color: textDark, fontSize: 13, fontWeight: FontWeight.w900),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  Text(location, style: TextStyle(color: textDark.withValues(alpha: 0.8), fontSize: 11)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (price.isNotEmpty)
                                        Text(price, style: const TextStyle(color: deepBlueIcon, fontWeight: FontWeight.w900, fontSize: 11.5)),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.star, color: sunnyGold, size: 13),
                                      const SizedBox(width: 2),
                                      Text(rating, style: const TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.favorite, color: Colors.redAccent, size: 22),
                                onPressed: () => DataService.toggleFavorite(item),
                              ),
                              onTap: () => _navigateToDetail(context, item),
                            ),
                          );
                        },
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