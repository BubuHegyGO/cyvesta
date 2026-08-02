import 'package:flutter/material.dart';
import 'package:hegygo/features/accommodation/presentation/accommodation_detail_page.dart';

class AccommodationPage extends StatefulWidget {
  final bool isHighlight;

  const AccommodationPage({
    super.key,
    this.isHighlight = false,
  });

  @override
  State<AccommodationPage> createState() => _AccommodationPageState();
}

class _AccommodationPageState extends State<AccommodationPage> {
  final List<Map<String, String>> _accommodations = [
    {
      'id': '1',
      'title': 'Szarvas Vendégház',
      'subtitle': 'vendégház a Kékesen',
      'priceTag': '10.000 Ft / fő / éj-től',
      'imagePath': 'assets/images/szarvas.png',
      'location': 'Mátra - Kékestető',
      'price': '10.000 Ft / fő / éj-től',
      'rating': '4.9',
      'description': 'Kényelmes, fenyvesekkel körülvett hangulatos faház a Mátra szívében.',
      'isVerified': 'true',
      'type': 'accommodation',
    },
    {
      'id': '4',
      'title': 'Panoráma Apartman',
      'subtitle': 'apartman Mátraházán',
      'priceTag': '12.500 Ft / fő / éj-től',
      'imagePath': 'assets/images/panorama.png',
      'location': 'Mátra - Mátraháza',
      'price': '12.500 Ft / fő / éj-től',
      'rating': '4.8',
      'description': 'Modern, teljesen felszerelt apartman gyönyörű erdei panorámával.',
      'isVerified': 'true',
      'type': 'accommodation',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D160E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D160E),
        elevation: 0,
        title: Text(
          widget.isHighlight ? 'Kiemelt Szállások 🏡' : 'Összes Szállás 🏡',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _accommodations.length,
        itemBuilder: (context, index) {
          final item = _accommodations[index];
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
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF8BC541), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Image.asset(
                        item['imagePath']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[900],
                          child: const Icon(Icons.home, color: Color(0xFF8BC541), size: 50),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  item['rating']!,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['location']!,
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item['price']!,
                          style: const TextStyle(
                            color: Color(0xFF8BC541),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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
    );
  }
}