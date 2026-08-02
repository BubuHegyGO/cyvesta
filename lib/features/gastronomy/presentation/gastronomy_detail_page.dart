import 'package:flutter/material.dart';

class GastronomyDetailPage extends StatefulWidget {
  final Map<String, String> gastronomyData;

  const GastronomyDetailPage({super.key, required this.gastronomyData});

  @override
  State<GastronomyDetailPage> createState() => _GastronomyDetailPageState();
}

class _GastronomyDetailPageState extends State<GastronomyDetailPage> {
  final List<Map<String, String>> _menuItems = [
    {
      'title': 'HegyGO Kemencés Tál',
      'price': '4.800 Ft',
      'desc': 'Sült csülök, töltött dagadó, párolt káposzta, tepsis burgonya',
    },
    {
      'title': 'Bükki Vadgulyás Házi Csipetkével',
      'price': '3.200 Ft',
      'desc': 'Erdei gombákkal, friss kenyérrel és házi savanyúsággal',
    },
    {
      'title': 'Kézműves Erdei Gyümölcsös Pite',
      'price': '1.800 Ft',
      'desc': 'Helyi erdei gyümölcsökből, vanília fagylalttal',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final item = widget.gastronomyData;

    return Scaffold(
      backgroundColor: const Color(0xFF0D160E),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xFF1E3A1E),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    item['imagePath'] ?? 'assets/images/csarda.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/szarvas.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF1A261C),
                        child: const Icon(Icons.restaurant, color: Color(0xFF8BC541), size: 80),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          const Color(0xFF0D160E),
                        ],
                      ),
                    ),
                  ),
                  if (item['isVerified'] == 'true')
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF07130A).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF8BC541)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified, color: Color(0xFF8BC541), size: 16),
                            SizedBox(width: 6),
                            Text(
                              'ELLENŐRZÖTT PARTNER',
                              style: TextStyle(
                                color: Color(0xFF8BC541),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item['title'] ?? 'Gasztro Helyszín',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFFC107)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              item['rating'] ?? '5.0',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF8BC541), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        item['location'] ?? 'Hegyvidék',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'A vendéglőről',
                    style: TextStyle(
                      color: Color(0xFF8BC541),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['description'] ?? 'Autentikus hegyvidéki ízek, friss helyi alapanyagok és felejthetetlen hangulat.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.87), fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A261C),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF8BC541).withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.access_time_filled, color: Color(0xFF8BC541)),
                            SizedBox(width: 8),
                            Text(
                              'Nyitvatartás & Helyszín',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white24, height: 20),
                        _buildInfoRow(Icons.schedule, 'Hétfő - Csütörtök:', '11:30 - 21:00'),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.schedule, 'Péntek - Vasárnap:', '11:00 - 23:00'),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.map_outlined, 'Streetmap / Cím:', item['location'] ?? 'Fő út 12.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Kiemelt Étlap & Kínálat 🍽️',
                    style: TextStyle(
                      color: Color(0xFF8BC541),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: _menuItems.map((dish) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.restaurant_menu, color: Color(0xFFFFC107), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        dish['title']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        dish['price']!,
                                        style: const TextStyle(
                                          color: Color(0xFF8BC541),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dish['desc']!,
                                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // --- ÚJ: SÁRGA KIEMELT WEBOLDAL MEGTEKINTÉSE GOMB ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Weboldal megnyitási logika
                      },
                      icon: const Icon(Icons.language, color: Colors.black, size: 22),
                      label: const Text(
                        'Weboldal megtekintése',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107), // Kért sárga kiemelés
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}