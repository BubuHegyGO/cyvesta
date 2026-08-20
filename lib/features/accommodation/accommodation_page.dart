import 'package:flutter/material.dart';
import 'package:cyvesta/core/widgets/cyvesta_scaffold.dart';
import 'package:cyvesta/features/accommodation/presentation/accommodation_detail_page.dart';

class AccommodationPage extends StatefulWidget {
  const AccommodationPage({super.key});

  @override
  State<AccommodationPage> createState() => _AccommodationPageState();
}

class _AccommodationPageState extends State<AccommodationPage> {
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  final List<Map<String, String>> _accommodations = [
    {
      'id': '1',
      'title': 'Villa Coral Bay Luxury',
      'subtitle': '4-Bedroom Villa with Infinity Pool',
      'location': 'Kyrenia - Esentepe',
      'price': '€220 / night',
      'rating': '4.95',
      'imagePath': 'assets/images/szarvas.png',
      'description': 'Exclusive modern seafront villa with private pool and panoramic Mediterranean views.',
    },
    {
      'id': '2',
      'title': 'Blue Horizon Residence',
      'subtitle': 'Modern 2-Bedroom Condo',
      'location': 'Famagusta - Long Beach',
      'price': '€110 / night',
      'rating': '4.85',
      'imagePath': 'assets/images/panorama.png',
      'description': 'Contemporary condo steps away from the sandy shores of Long Beach with resort amenities.',
    },
    {
      'id': '3',
      'title': 'Aphrodite Sunset Penthouse',
      'subtitle': 'Panoramic Sea View Suite',
      'location': 'Paphos - Coral Bay',
      'price': '€165 / night',
      'rating': '4.92',
      'imagePath': 'assets/images/panorama.png',
      'description': 'Luxury rooftop apartment overlooking the sunset coast and marina.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CyvestaScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Stays & Luxury Villas 🏖️',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: mintGreenBorder, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: turquoiseGlass,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: mintGreenBorder, width: 1.6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Image.asset(
                        item['imagePath']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: deepBlueIcon,
                          child: const Icon(Icons.villa_outlined, color: mintGreenBorder, size: 50),
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
                              Expanded(
                                child: Text(
                                  item['title']!,
                                  style: const TextStyle(color: textDark, fontSize: 17, fontWeight: FontWeight.w900),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: sunnyGold, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['rating']!,
                                    style: const TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, color: deepBlueIcon, size: 15),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item['location']!,
                                  style: TextStyle(color: textDark.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: deepBlueIcon,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: mintGreenBorder.withValues(alpha: 0.6), width: 1),
                            ),
                            child: Text(
                              item['price']!,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}