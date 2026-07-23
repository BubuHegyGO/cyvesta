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

  final List<Map<String, dynamic>> _myAccommodations = [
    {
      'title': 'Mátrai Panoráma Vendégház',
      'location': 'Mátraháza (Mátra)',
      'price': '35.000 Ft / éj',
      'status': 'Aktív',
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
        title: const Text('Saját Szállásaim 🏡', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Új szállás feladása', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAccommodationPage()),
          );
        },
      ),
      body: SafeArea(
        child: _myAccommodations.isEmpty
            ? const Center(
                child: Text(
                  'Még nem adtál fel szálláshirdetést.',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _myAccommodations.length,
                itemBuilder: (context, index) {
                  final item = _myAccommodations[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accent.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            item['image'],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'],
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['location'],
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['price'],
                                style: const TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: accent),
                          ),
                          child: Text(
                            item['status'],
                            style: const TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}