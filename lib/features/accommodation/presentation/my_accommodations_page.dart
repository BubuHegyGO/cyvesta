import 'package:flutter/material.dart';
import 'package:cyvesta/features/accommodation/presentation/add_accommodation_page.dart';
import 'package:cyvesta/features/accommodation/presentation/edit_accommodation_page.dart';

class MyAccommodationsPage extends StatefulWidget {
  const MyAccommodationsPage({super.key});

  @override
  State<MyAccommodationsPage> createState() => _MyAccommodationsPageState();
}

class _MyAccommodationsPageState extends State<MyAccommodationsPage> {
  static const Color bgColor = Color(0xFF0A1220);
  static const Color cardBg = Color(0xFF111E36);
  static const Color accentCyan = Color(0xFF00C0D4);

  final List<Map<String, String>> _myAccommodations = [
    {
      'id': '1',
      'title': 'Villa Coral Bay',
      'location': 'Kyrenia - Esentepe',
      'price': '€220 / night',
      'status': 'Active',
      'imagePath': 'assets/images/szarvas.png',
      'description': 'Exclusive modern 4-bedroom villa with private infinity pool and panoramic Mediterranean sea views.',
    },
    {
      'id': '2',
      'title': 'Blue Horizon Residence',
      'location': 'Famagusta - Long Beach',
      'price': '€110 / night',
      'status': 'Pending Review',
      'imagePath': 'assets/images/panorama.png',
      'description': 'Contemporary condo steps away from the sandy shores of Long Beach with resort amenities.',
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
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E192D),
        elevation: 0,
        title: const Text(
          'My Listings & Properties',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ADD NEW LISTING BUTTON
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
                  'Post New Listing',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentCyan,
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
                'Your active & pending listings (tap to edit):',
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
                  final bool isActive = item['status'] == 'Active';

                  return GestureDetector(
                    onTap: () => _openEditPage(item),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive ? accentCyan : Colors.amber,
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
                                    child: const Icon(Icons.villa_outlined, color: accentCyan),
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
                                            color: accentCyan,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? accentCyan.withValues(alpha: 0.15)
                                                : Colors.amber.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: isActive ? accentCyan : Colors.amber,
                                            ),
                                          ),
                                          child: Text(
                                            item['status']!,
                                            style: TextStyle(
                                              color: isActive ? accentCyan : Colors.amber,
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
                                icon: const Icon(Icons.edit, color: accentCyan, size: 18),
                                label: const Text(
                                  'Edit & Update Pricing',
                                  style: TextStyle(
                                    color: accentCyan,
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