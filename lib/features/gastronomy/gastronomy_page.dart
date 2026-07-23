import 'package:flutter/material.dart';

class GastronomyPage extends StatefulWidget {
  const GastronomyPage({super.key});

  @override
  State<GastronomyPage> createState() => _GastronomyPageState();
}

class _GastronomyPageState extends State<GastronomyPage> {
  static const Color bgColor = Color(0xFF07130A);
  static const Color accent = Color(0xFF8BC541);

  String _selectedCategory = 'Összes';

  final List<String> _categories = const [
    'Összes',
    'Csárda & Étterem',
    'Borászat & Pince',
    'Helyi Termelő',
    'Erdei Bisztró',
  ];

  final List<Map<String, dynamic>> _gastronomyList = const [
    {
      'title': 'Mátrai Csárda & Borozó',
      'location': 'Mátrafüred',
      'region': 'Mátra',
      'category': 'Csárda & Étterem',
      'rating': '4.9',
      'specialty': 'Szarvaspörkölt sztrapacskával',
      'priceRange': '3.500 - 8.000 Ft / fő',
      'image': 'assets/images/matra_background.png',
      'badge': 'Hagyományos Ízek',
    },
    {
      'title': 'Zempléni Borászati Birtok',
      'location': 'Tokaj-Hegyalja',
      'region': 'Zempléni-hegység',
      'category': 'Borászat & Pince',
      'rating': '5.0',
      'specialty': 'Borkóstoló & Sajttál',
      'priceRange': '5.000 - 12.000 Ft / fő',
      'image': 'assets/images/matra_background.png',
      'badge': 'Díjnyertes Borok',
    },
    {
      'title': 'Bükki Erdei Sajtműhely',
      'location': 'Cserépfalu',
      'region': 'Bükk',
      'category': 'Helyi Termelő',
      'rating': '4.8',
      'specialty': 'Kézműves kecskesajtok',
      'priceRange': '2.000 - 6.000 Ft / csomag',
      'image': 'assets/images/matra_background.png',
      'badge': 'Bio / Termelői',
    },
    {
      'title': 'Bakonyi Vadászház Bisztró',
      'location': 'Bakonybél',
      'region': 'Bakony',
      'category': 'Erdei Bisztró',
      'rating': '4.9',
      'specialty': 'Erdei gombás vadraguleves',
      'priceRange': '4.000 - 9.000 Ft / fő',
      'image': 'assets/images/matra_background.png',
      'badge': 'Panorámás Terasz',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredGastronomy = _selectedCategory == 'Összes'
        ? _gastronomyList
        : _gastronomyList.where((item) => item['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text(
          'Hegyvidéki Gasztro 🍷',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // KATEGÓRIA SZŰRŐ
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: accent,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      side: BorderSide(color: isSelected ? accent : Colors.white12),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // GASZTRO LISTA
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: filteredGastronomy.length,
                itemBuilder: (context, index) {
                  final item = filteredGastronomy[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Stack(
                            children: [
                              Image.asset(
                                item['image'],
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: accent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item['badge'],
                                    style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        item['rating'],
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'],
                                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, color: accent, size: 15),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item['location']} (${item['region']})',
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.restaurant_menu_rounded, color: Colors.amber, size: 15),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'A ház specialitása: ${item['specialty']}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(color: Colors.white12),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['priceRange'],
                                    style: const TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accent,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Asztalfoglalás / Útvonal ide: ${item['title']}'),
                                          backgroundColor: accent,
                                        ),
                                      );
                                    },
                                    child: const Text('Asztalfoglalás', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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