import 'package:flutter/material.dart';
import '../../core/services/data_service.dart';
import '../accommodation/presentation/accommodation_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  static const Color bgColor = Color(0xFF07130A);
  static const Color accent = Color(0xFF8BC541);

  final DataService _dataService = DataService();

  List<Map<String, dynamic>> _getFavorites() {
    final all = [..._dataService.getAccommodations(), ..._dataService.getExperiences()];
    return all.where((item) => item['isFavorite'] == true).toList();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = _getFavorites();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FEJLÉC
              const Text(
                'Mentett Kedvencek',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'A kedvencnek jelölt szállásaid és élményeid egy helyen.',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),

              const SizedBox(height: 20),

              // LISTA VAGY ÜRES ÁLLAPOT
              Expanded(
                child: favorites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border_rounded,
                              size: 64,
                              color: accent.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Még nincs elmentett kedvenced',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Kattints a szív ikonra a szállások kártyáin a mentéshez!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white54, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final item = favorites[index];
                          return _buildFavoriteCard(item);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccommodationDetailPage(accommodationData: item),
            ),
          ).then((_) => setState(() {}));
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
              child: Image.asset(
                item['image'] ?? 'assets/images/matra_background.png',
                width: 110,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['category'] ?? '',
                    style: const TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['title'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['location'] ?? '',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['price'] ?? '',
                    style: const TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
              onPressed: () {
                setState(() {
                  _dataService.toggleFavorite(item['id']);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}