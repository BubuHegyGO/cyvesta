import 'package:flutter/material.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/services/data_service.dart';
import '../../../core/widgets/cyvesta_scaffold.dart';
import 'accommodation_detail_page.dart';

class AccommodationListPage extends StatefulWidget {
  final String filterType; // 'rent' vagy 'sale'
  final String pageTitle;

  const AccommodationListPage({
    super.key,
    required this.filterType,
    required this.pageTitle,
  });

  @override
  State<AccommodationListPage> createState() => _AccommodationListPageState();
}

class _AccommodationListPageState extends State<AccommodationListPage> {
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  String _searchQuery = '';

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
                          widget.pageTitle,
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: deepBlueIcon,
                      hintText: locale == 'hu' ? 'Keresés város vagy név szerint...' : 'Search by city or property name...',
                      hintStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                      prefixIcon: const Icon(Icons.search_rounded, color: sunnyGold, size: 20),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: mintGreenBorder, width: 1.2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: mintGreenBorder, width: 1.2)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: DataService.accommodations,
                    builder: (context, allItems, child) {
                      final items = allItems.where((item) {
                        if (item['status'] == 'rejected') return false;
                        
                        // Kategória és szűrés igazítása
                        final cat = item['category']?.toString().toLowerCase() ?? '';
                        if (cat != 'accommodation' && cat != 'rent' && cat != 'sale') return false;

                        if (widget.filterType == 'sale') {
                          if (cat != 'sale' && !item['price'].toString().contains('€320')) return false;
                        } else {
                          if (cat == 'sale') return false;
                        }

                        if (_searchQuery.isNotEmpty) {
                          final title = item['title']?.toString().toLowerCase() ?? '';
                          final loc = item['location']?.toString().toLowerCase() ?? '';
                          if (!title.contains(_searchQuery) && !loc.contains(_searchQuery)) {
                            return false;
                          }
                        }

                        return true;
                      }).toList();

                      if (items.isEmpty) {
                        return Center(
                          child: Text(
                            locale == 'hu' ? 'Nincs találat a megadott szűrésre.' : 'No listings found for this category.',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final title = item['title']?.toString() ?? '';
                          final location = item['location']?.toString() ?? '';
                          final price = item['price']?.toString() ?? '';
                          final rating = item['rating']?.toString() ?? '4.95';
                          final imagePath = item['imagePath']?.toString() ?? 'assets/images/szarvas.png';

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
                                        errorBuilder: (c, e, s) => Container(
                                          height: 180,
                                          color: deepBlueIcon,
                                          child: const Icon(Icons.villa_rounded, size: 50, color: mintGreenBorder),
                                        ),
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
                                            child: Text(
                                              price,
                                              style: const TextStyle(color: sunnyGold, fontSize: 12, fontWeight: FontWeight.w900),
                                            ),
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
                                                MaterialPageRoute(builder: (context) => AccommodationDetailPage(accommodationData: item)),
                                              );
                                            },
                                            child: Text(
                                              AppLanguage.tr('view_details'),
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