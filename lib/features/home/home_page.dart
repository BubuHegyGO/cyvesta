import 'package:flutter/material.dart';
import '../accommodation/presentation/accommodation_detail_page.dart';
import '../notifications/notifications_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color bgColor = Color(0xFF07130A);
  static const Color accent = Color(0xFF8BC541);

  final List<Map<String, dynamic>> _accommodations = [
    {
      'id': '1',
      'title': 'Mátrai Panoráma Vendégház',
      'location': 'Mátraháza',
      'price': '35.000 Ft / éj',
      'rating': '4.9',
      'image': 'assets/images/matra_background.png',
      'isFeatured': true,
    },
    {
      'id': '2',
      'title': 'Erdei Kuckó faház',
      'location': 'Galyatető',
      'price': '28.000 Ft / éj',
      'rating': '4.8',
      'image': 'assets/images/matra_background.png',
      'isFeatured': false,
    },
    {
      'id': '3',
      'title': 'Hegyvidéki Wellness Apartman',
      'location': 'Parádfürdő',
      'price': '42.000 Ft / éj',
      'rating': '5.0',
      'image': 'assets/images/matra_background.png',
      'isFeatured': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FEJLÉC (CÍM ÉS ÉRTÉSÍTÉSEK HARANG IKON)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HegyGO 🌲',
                        style: TextStyle(
                          color: accent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Fedezd fel a Mátra kincseit!',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),

                  // ÉRTÉSÍTÉSEK GOMB HARANG PIROS JELZÉSSEL
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationsPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // KIEMELT PARTNER BANNER SZEKCIÓ
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent.withValues(alpha: 0.2), Colors.black54],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.stars_rounded, color: accent, size: 36),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Közvetlen foglalás 0% jutalékkal!',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Foglald le kedvenc szállásodat közvetlenül a szállásadótól.',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // KIEMELT SZÁLLÁSOK CÍM
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kiemelt Szálláshelyek',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Összes',
                    style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // SZÁLLÁSKÁRTYÁK LISTÁJA
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _accommodations.length,
                itemBuilder: (context, index) {
                  final item = _accommodations[index];
                  return _buildAccommodationCard(context, item);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccommodationCard(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccommodationDetailPage(accommodationData: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KÉP
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  Image.asset(
                    item['image'],
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  if (item['isFeatured'] == true)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Kiemelt',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ADATOK
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['title'],
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            item['rating'],
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: accent, size: 15),
                          const SizedBox(width: 4),
                          Text(
                            item['location'],
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      Text(
                        item['price'],
                        style: const TextStyle(color: accent, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}