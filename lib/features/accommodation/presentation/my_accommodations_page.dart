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

  // Minta adatok a felület teszteléséhez (NTAK számmal és jóváhagyási státusszal)
  final List<Map<String, dynamic>> _myAccommodations = [
    {
      'title': 'Mátrai Panoráma Vendégház',
      'location': 'Mátrafüred',
      'ntak': 'EG19001234',
      'price': '35.000 Ft / éj',
      'status': 'pending', // 'pending' (ellenőrzés alatt) vagy 'approved' (jóváhagyva)
      'image': 'assets/images/sample_cabin.jpg',
    },
    {
      'title': 'Bükki Kabin & Jacuzzi',
      'location': 'Szilvásvárad',
      'ntak': 'MA20005678',
      'price': '48.000 Ft / éj',
      'status': 'approved',
      'image': 'assets/images/sample_cabin2.jpg',
    },
  ];

  void _openAddAccommodation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddAccommodationPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text(
          'Saját Szállásaim 🏡',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: accent, size: 28),
            tooltip: 'Új szállás feladása',
            onPressed: _openAddAccommodation,
          ),
        ],
      ),
      body: SafeArea(
        child: _myAccommodations.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _myAccommodations.length,
                itemBuilder: (context, index) {
                  final item = _myAccommodations[index];
                  return _buildAccommodationCard(item);
                },
              ),
      ),
      // 🔑 ÚJ SZÁLLÁS HOZZÁADÁSA GOMB A JOBB ALSÓ SAROKBAN
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddAccommodation,
        backgroundColor: accent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded, size: 26),
        label: const Text(
          'Új szállás',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildAccommodationCard(Map<String, dynamic> item) {
    final bool isApproved = item['status'] == 'approved';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isApproved ? accent.withValues(alpha: 0.3) : Colors.amber.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Szállás Képe / Helyőrző
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: Colors.white10,
                    child: const Icon(Icons.home_work_rounded, color: Colors.white54, size: 40),
                  ),
                ),
                const SizedBox(width: 12),

                // Cím, Helyszín, NTAK
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: accent, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            item['location'],
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // NTAK Szám megjelenítése
                      Text(
                        'NTAK: ${item['ntak']}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white12, height: 20),

            // Státusz Jelvény & Ár
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(item['status']),
                Text(
                  item['price'],
                  style: const TextStyle(
                    color: accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Státusz Jelvény (Badge) Widget
  Widget _buildStatusBadge(String status) {
    final bool isApproved = status == 'approved';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isApproved ? Colors.green.withValues(alpha: 0.15) : Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isApproved ? Colors.green : Colors.amber,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isApproved ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
            size: 14,
            color: isApproved ? Colors.green : Colors.amber,
          ),
          const SizedBox(width: 6),
          Text(
            isApproved ? 'Jóváhagyva' : 'Admin ellenőrzés alatt',
            style: TextStyle(
              color: isApproved ? Colors.green : Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.house_siding_rounded, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            'Még nem adtál fel szállást.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _openAddAccommodation,
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Szállás feladása', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}