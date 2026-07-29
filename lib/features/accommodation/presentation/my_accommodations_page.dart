import 'package:flutter/material.dart';
import 'package:hegygo/features/accommodation/presentation/add_accommodation_page.dart';
import 'package:hegygo/features/accommodation/presentation/edit_accommodation_page.dart';

class MyAccommodationsPage extends StatefulWidget {
  const MyAccommodationsPage({super.key});

  @override
  State<MyAccommodationsPage> createState() => _MyAccommodationsPageState();
}

class _MyAccommodationsPageState extends State<MyAccommodationsPage> {
  final List<Map<String, String>> _myAccommodations = [
    {
      'id': '1',
      'title': 'SZARVAS vendégház',
      'location': 'Mátra - Kékestető',
      'price': '10.000 Ft / fő / éj',
      'status': 'Aktív',
      'imagePath': 'assets/images/szarvas.png',
      'description': 'Kényelmes, fenyvesekkel körülvett hangulatos faház a Mátra szívében.',
    },
    {
      'id': '2',
      'title': 'Panoráma Apartman',
      'location': 'Mátra - Mátraháza',
      'price': '12.500 Ft / fő / éj',
      'status': 'Elbírálás alatt',
      'imagePath': 'assets/images/panorama.png',
      'description': 'Lélegzetelállító erdei és völgyi panorámával rendelkező modern, teljesen felszerelt apartman.',
    },
  ];

  void _openEditPage(Map<String, String> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAccommodationPage(accommodationData: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D160E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A1E),
        elevation: 0,
        title: const Text(
          'Saját Szállásaim',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ÚJ SZÁLLÁS HOZZÁADÁSA GOMB
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddAccommodationPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle_outline, color: Colors.black),
                label: const Text(
                  'Új Szállás Feltöltése',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8BC541),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Meglévő szálláshirdetéseid (kattints a szerkesztéshez):',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: _myAccommodations.length,
                itemBuilder: (context, index) {
                  final item = _myAccommodations[index];
                  final bool isActive = item['status'] == 'Aktív';

                  return GestureDetector(
                    onTap: () => _openEditPage(item),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A261C),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive ? const Color(0xFF8BC541) : Colors.amber,
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  item['imagePath']!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.black26,
                                    child: const Icon(Icons.home, color: Color(0xFF8BC541)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['location']!,
                                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item['price']!,
                                          style: const TextStyle(
                                            color: Color(0xFF8BC541),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isActive ? const Color(0xFF8BC541).withValues(alpha: 0.2) : Colors.amber.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: isActive ? const Color(0xFF8BC541) : Colors.amber,
                                            ),
                                          ),
                                          child: Text(
                                            item['status']!,
                                            style: TextStyle(
                                              color: isActive ? const Color(0xFF8BC541) : Colors.amber,
                                              fontSize: 10,
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
                          const Divider(color: Colors.white12, height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _openEditPage(item),
                                icon: const Icon(Icons.edit, color: Color(0xFF8BC541), size: 18),
                                label: const Text(
                                  'Szerkesztés & Árváltoztatás',
                                  style: TextStyle(
                                    color: Color(0xFF8BC541),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}