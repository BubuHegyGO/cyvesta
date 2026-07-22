import 'package:flutter/material.dart';
import '../accommodation/presentation/accommodation_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const Color bgColor = Color(0xFF07130A);
  static const Color accent = Color(0xFF8BC541);

  String _searchQuery = '';
  String _selectedRegion = 'Összes'; // Alapértelmezett: Összes hegyvidék

  // Magyarország hegyvidékei / régiói
  final List<String> _regions = const [
    'Összes',
    'Mátra',
    'Bükk',
    'Börzsöny',
    'Bakony',
    'Zemplén',
    'Kőszegi-hegység',
    'Cserhát',
    'Mecsek',
  ];

  // Minta adatbázis az ország különböző hegyvidékeiről
  final List<Map<String, dynamic>> _allAccommodations = const [
    {
      'id': '1',
      'title': 'Mátrai Panoráma Vendégház',
      'location': 'Mátraháza',
      'region': 'Mátra',
      'price': '35.000 Ft / éj',
      'rating': '4.9',
      'image': 'assets/images/matra_background.png',
      'category': 'Vendégház',
    },
    {
      'id': '2',
      'title': 'Bükki Szikla Chalet',
      'location': 'Szilvásvárad',
      'region': 'Bükk',
      'price': '45.000 Ft / éj',
      'rating': '5.0',
      'image': 'assets/images/matra_background.png',
      'category': 'Lakház',
    },
    {
      'id': '3',
      'title': 'Börzsönyi Patakparti Kuckó',
      'location': 'Zebegény',
      'region': 'Börzsöny',
      'price': '30.000 Ft / éj',
      'rating': '4.8',
      'image': 'assets/images/matra_background.png',
      'category': 'Faház',
    },
    {
      'id': '4',
      'title': 'Bakonyi Erdei Wellness Villa',
      'location': 'Bakonybél',
      'region': 'Bakony',
      'price': '38.000 Ft / éj',
      'rating': '4.9',
      'image': 'assets/images/matra_background.png',
      'category': 'Apartman',
    },
    {
      'id': '5',
      'title': 'Zempléni Várpanoráma Vendégház',
      'location': 'Füzér',
      'region': 'Zemplén',
      'price': '32.000 Ft / éj',
      'rating': '4.7',
      'image': 'assets/images/matra_background.png',
      'category': 'Vendégház',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Szűrés név, település ÉS hegyvidéki régió alapján
    final filteredList = _allAccommodations.where((item) {
      final matchesSearch = item['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['location'].toString().toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesRegion = _selectedRegion == 'Összes' || item['region'] == _selectedRegion;

      return matchesSearch && matchesRegion;
    }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CÍMSOR
              const Text(
                'Keresés Hegységek Szerint 🏔️',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Válassz a magyar hegyvidékek közül!',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),

              const SizedBox(height: 16),

              // KERESŐ MEZŐ
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Keresés név vagy település alapján...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: accent),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.35),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: accent),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // HEGYVIDÉK / RÉGIÓ SZŰRŐ CHIP-EK (GÖRGETHETŐ SÁV)
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _regions.length,
                  itemBuilder: (context, index) {
                    final region = _regions[index];
                    final isSelected = _selectedRegion == region;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(region),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        backgroundColor: Colors.black.withValues(alpha: 0.35),
                        selectedColor: accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? accent : Colors.white12,
                          ),
                        ),
                        showCheckmark: false,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedRegion = region;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // TALÁLATOK SZÁMA ÉS LISTÁJA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Találatok (${filteredList.length})',
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  if (_selectedRegion != 'Összes')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Régió: $_selectedRegion',
                        style: const TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              Expanded(
                child: filteredList.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.terrain_rounded, color: Colors.white24, size: 48),
                            SizedBox(height: 12),
                            Text(
                              'Nincs találat ebben a hegyvidékben.',
                              style: TextStyle(color: Colors.white54, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          return _buildSearchCard(context, item);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccommodationDetailPage(accommodationData: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            // KÉP HEGYSÉG BADGE-EL
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.asset(
                    item['image'],
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item['region'],
                        style: const TextStyle(color: accent, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // RÉSZLETEK
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: accent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${item['location']} (${item['region']})',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['price'],
                        style: const TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            item['rating'],
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
      ),
    );
  }
}