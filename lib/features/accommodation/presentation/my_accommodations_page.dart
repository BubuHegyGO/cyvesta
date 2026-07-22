import 'package:flutter/material.dart';
import 'add_accommodation_page.dart';

class MyAccommodationsPage extends StatefulWidget {
  const MyAccommodationsPage({super.key});

  @override
  State<MyAccommodationsPage> createState() => _MyAccommodationsPageState();
}

class _MyAccommodationsPageState extends State<MyAccommodationsPage> {
  static const Color bgColor = Color(0xFF07130A);
  static const Color accent = Color(0xFF8BC541);

  // Minta adatok a felület teszteléséhez
  final List<Map<String, dynamic>> _myAccommodations = [
    {
      'title': 'Mátrai Panoráma Lombház',
      'ntak': 'EG12345678',
      'city': 'Mátrafüred',
      'price': '35 000 Ft / éj',
      'status': 'pending', // pending: Admin ellenőrzés alatt
      'image': 'assets/images/matra_background.png',
    },
    {
      'title': 'Bükki Menedék Faház',
      'ntak': 'MA87654321',
      'city': 'Szilvásvárad',
      'price': '28 000 Ft / éj',
      'status': 'active', // active: Aktív / Foglalható
      'image': 'assets/images/matra_background.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Saját szállásaim',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: accent, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddAccommodationPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _myAccommodations.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _myAccommodations.length,
                itemBuilder: (context, index) {
                  final accommodation = _myAccommodations[index];
                  return _buildAccommodationCard(accommodation);
                },
              ),
      ),
    );
  }

  Widget _buildAccommodationCard(Map<String, dynamic> item) {
    final bool isActive = item['status'] == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive ? accent.withValues(alpha: 0.3) : Colors.amber.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kép & Státusz jelvény
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.asset(
                  item['image'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? accent : Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                        size: 14,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isActive ? 'Aktív' : 'Admin ellenőrzés alatt',
                        style: const TextStyle(
                          color: Colors.black,
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

          // Szállás adatai
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.white54, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      item['city'],
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.verified_outlined, color: Colors.white54, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'NTAK: ${item['ntak']}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['price'],
                      style: const TextStyle(
                        color: accent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert_rounded, color: Colors.white70, size: 20),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.villa_outlined, size: 70, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text(
              'Még nincs feltöltött szálláshelyed',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Regisztráld a szálláshelyedet, és jelenj meg a HegyGO kínálatában!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}