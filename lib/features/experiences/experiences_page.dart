import 'package:flutter/material.dart';
import 'package:hegygo/features/experiences/presentation/experience_detail_page.dart';

class ExperiencesPage extends StatefulWidget {
  const ExperiencesPage({super.key});

  @override
  State<ExperiencesPage> createState() => _ExperiencesPageState();
}

class _ExperiencesPageState extends State<ExperiencesPage> {
  final List<Map<String, String>> _experiences = [
    {
      'id': '1',
      'title': 'Quad Túra a Bükkben',
      'location': 'Bükk - Szilvásvárad',
      'price': '8.000 Ft / fő-től',
      'rating': '4.95',
      'description': 'Lélegzetelállító erdei utak, profi túravezetés és garantált adrenalinfröccs a Bükki Nemzeti Park szélén.',
      'imagePath': 'assets/images/quad.png',
      'isVerified': 'true',
    },
    {
      'id': '2',
      'title': 'Kékesi Libegő & Panoráma',
      'location': 'Mátra - Mátrafüred',
      'price': '3.500 Ft / fő-től',
      'rating': '4.7',
      'description': 'Csodáld meg a Mátra vonulatait a magasból! Családi program kiváló fotózkodási lehetőségekkel és csodás erdei panorámával.',
      'imagePath': 'assets/images/szarvas.png', // Létező képre cserélve
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
          'Élmények',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _experiences.length,
        itemBuilder: (context, index) {
          final item = _experiences[index];
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
            builder: (context) => ExperienceDetailPage(experienceData: item),
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
                          child: const Icon(Icons.terrain, color: Color(0xFF8BC541), size: 60),
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
                            fontSize: 15,
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
                            'Jelentkezés',
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