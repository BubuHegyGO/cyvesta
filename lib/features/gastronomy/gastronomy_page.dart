import 'package:flutter/material.dart';
import 'package:hegygo/features/gastronomy/presentation/gastronomy_detail_page.dart';

class GastronomyPage extends StatefulWidget {
  const GastronomyPage({super.key});

  @override
  State<GastronomyPage> createState() => _GastronomyPageState();
}

class _GastronomyPageState extends State<GastronomyPage> {
  final List<Map<String, String>> _gastronomyItems = [
    {
      'id': '1',
      'title': 'Mecseki Borozó & Csárda',
      'location': 'Mecsek - Villányi borvidék',
      'price': 'Asztalfoglalás / Kóstoló',
      'rating': '4.9',
      'description': 'Hagyományos borvidéki pince és csárda. Saját termelésű prémium borok, kemencés sültek és élő cigányzene hétvégente.',
      'imagePath': 'assets/images/csarda.png',
      'isVerified': 'true',
    },
    {
      'id': '2',
      'title': 'Erdei Süti Kézműves Cukrászda',
      'location': 'Bükk - Miskolctapolca',
      'price': 'Sütemények & Specialty Kávék',
      'rating': '4.85',
      'description': 'Frissen sült erdei gyümölcsös piték, kézműves fagylaltok és specialty kávék a fenyvesek tövében.',
      'imagePath': 'assets/images/cukraszda.png',
      'isVerified': 'true',
    },
    {
      'id': '3',
      'title': 'Vár Étterem & Vadgasztro',
      'location': 'Mátra - Sirok',
      'price': 'Hagyományos & Vadételek',
      'rating': '4.75',
      'description': 'Házias magyaros ételek, vadételek és helyi specialitások gyönyörű panorámás terasszal.',
      'imagePath': 'assets/images/etterem.png',
      'isVerified': 'true',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D160E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A1E),
        elevation: 0,
        title: const Text(
          'Gasztro',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _gastronomyItems.length,
        itemBuilder: (context, index) {
          final item = _gastronomyItems[index];
          return _buildCard(context, item);
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, Map<String, String> item) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GastronomyDetailPage(gastronomyData: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A261C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF8BC541).withValues(alpha: 0.4), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        item['imagePath']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF1A261C),
                          child: const Icon(Icons.restaurant, color: Color(0xFF8BC541), size: 60),
                        ),
                      ),
                    ),
                    if (item['isVerified'] == 'true')
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF07130A).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF8BC541), width: 1),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: Color(0xFF8BC541), size: 14),
                              SizedBox(width: 4),
                              Text(
                                'ELLENŐRZÖTT PARTNER',
                                style: TextStyle(
                                  color: Color(0xFF8BC541),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFC107)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Color(0xFFFFC107), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              item['rating']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF8BC541), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          item['location']!,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['price']!,
                          style: const TextStyle(
                            color: Color(0xFF8BC541),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A1E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF8BC541)),
                          ),
                          child: const Text(
                            'Megnézem', // Módosítva
                            style: TextStyle(
                              color: Color(0xFF8BC541),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}