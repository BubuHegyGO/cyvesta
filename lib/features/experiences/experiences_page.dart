
import 'package:flutter/material.dart';

class ExperiencesPage extends StatefulWidget {
  const ExperiencesPage({super.key});

  @override
  State<ExperiencesPage> createState() => _ExperiencesPageState();
}

class _ExperiencesPageState extends State<ExperiencesPage> {
  static const Color bgColor = Color(0xFF07130A);
  static const Color accent = Color(0xFF8BC541);

  String _selectedCategory = 'Összes';

  final List<String> _categories = const [
    'Összes',
    'Túrázás',
    'E-bike & Bringa',
    'Extrém Sport',
    'Családi',
    'Vízi Élmény',
  ];

  final List<Map<String, dynamic>> _experiencesList = const [
    {
      'title': 'Vezetett E-bike Túra a Mátra Bércein',
      'location': 'Galyatető',
      'region': 'Mátra',
      'category': 'E-bike & Bringa',
      'duration': '3-4 óra',
      'difficulty': 'Közepes',
      'rating': '4.9',
      'price': '12.500 Ft / fő',
      'guide': 'Mátra Bike Csapat',
      'image': 'assets/images/matra_background.png',
      'badge': 'Felszereléssel',
    },
    {
      'title': 'Sziklamászás & Via Ferrata',
      'location': 'Csesznek',
      'region': 'Bakony',
      'category': 'Extrém Sport',
      'duration': '2-3 óra',
      'difficulty': 'Haladó',
      'rating': '5.0',
      'price': '15.000 Ft / fő',
      'guide': 'Bakony Adventure',
      'image': 'assets/images/matra_background.png',
      'badge': 'Profi Vezetővel',
    },
    {
      'title': 'Éjszakai Csillagnéző Túra a Bükkben',
      'location': 'Répáshuta',
      'region': 'Bükk',
      'category': 'Túrázás',
      'duration': '2 óra',
      'difficulty': 'Könnyű',
      'rating': '4.8',
      'price': '6.500 Ft / fő',
      'guide': 'Bükki Csillagda',
      'image': 'assets/images/matra_background.png',
      'badge': 'Teleszkóppal',
    },
    {
      'title': 'Kajaktúra a Dunakanyarban',
      'location': 'Zebegény',
      'region': 'Börzsöny',
      'category': 'Vízi Élmény',
      'duration': '4 óra',
      'difficulty': 'Könnyű',
      'rating': '4.9',
      'price': '9.900 Ft / fő',
      'guide': 'Dunakanyar Water Sports',
      'image': 'assets/images/matra_background.png',
      'badge': 'Mentőmellénnyel',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredExperiences = _selectedCategory == 'Összes'
        ? _experiencesList
        : _experiencesList.where((item) => item['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text(
          'Hegyvidéki Élmények 🌲',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // KATEGÓRIA SZŰRŐ SOR
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

            // ÉLMÉNYEK LISTÁJA
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: filteredExperiences.length,
                itemBuilder: (context, index) {
                  final item = filteredExperiences[index];
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
                                  const Spacer(),
                                  const Icon(Icons.timer_outlined, color: Colors.white54, size: 15),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['duration'],
                                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(color: Colors.white12),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Szervező: ${item['guide']}',
                                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item['price'],
                                        style: const TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ],
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
                                          content: Text('Jelentkezés az élményre: ${item['title']}'),
                                          backgroundColor: accent,
                                        ),
                                      );
                                    },
                                    child: const Text('Foglalás', style: TextStyle(fontWeight: FontWeight.bold)),
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