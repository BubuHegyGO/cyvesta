import 'package:flutter/material.dart';
import 'package:cyvesta/core/localization/app_language.dart';
import 'package:cyvesta/features/accommodation/presentation/accommodation_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // --- CYVESTA GLASS & MINT THEME ---
  static const Color darkBg = Color(0xFF061822);
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  final TextEditingController _searchController = TextEditingController();
  String _selectedRegion = 'All';

  final List<String> _regions = [
    'All',
    'Kyrenia',
    'Paphos',
    'Limassol',
    'Famagusta',
    'Ayia Napa',
    'Larnaca',
  ];

  final List<Map<String, String>> _allProperties = [
    {
      'id': '1',
      'title': 'Villa Coral Bay Luxury',
      'subtitle': '4-Bedroom Villa with Infinity Pool',
      'region': 'Kyrenia',
      'location': 'Kyrenia - Esentepe',
      'price': '€220 / night',
      'rating': '4.95',
      'imagePath': 'assets/images/szarvas.png',
      'description': 'Exclusive modern seafront villa with private pool and panoramic Mediterranean views.',
      'type': 'accommodation',
    },
    {
      'id': '2',
      'title': 'Blue Horizon Residence',
      'subtitle': 'Modern 2-Bedroom Apartment',
      'region': 'Famagusta',
      'location': 'Famagusta - Long Beach',
      'price': '€110 / night',
      'rating': '4.85',
      'imagePath': 'assets/images/panorama.png',
      'description': 'Contemporary condo steps away from the sandy shores of Long Beach with resort amenities.',
      'type': 'accommodation',
    },
    {
      'id': '3',
      'title': 'Aphrodite Sunset Penthouse',
      'subtitle': 'Panoramic Sea View Suite',
      'region': 'Paphos',
      'location': 'Paphos - Coral Bay',
      'price': '€165 / night',
      'rating': '4.92',
      'imagePath': 'assets/images/panorama.png',
      'description': 'Luxury rooftop apartment overlooking the sunset coast and marina.',
      'type': 'accommodation',
    },
    {
      'id': '4',
      'title': 'Marina Crown Royal Suite',
      'subtitle': 'Beachfront Modern Residence',
      'region': 'Limassol',
      'location': 'Limassol Marina',
      'price': '€195 / night',
      'rating': '4.88',
      'imagePath': 'assets/images/csarda.png',
      'description': 'Prime location right at the marina with world-class restaurants at your doorstep.',
      'type': 'accommodation',
    },
    {
      'id': '5',
      'title': 'Nissi Sands Beach Villa',
      'subtitle': 'Steps away from Nissi Beach',
      'region': 'Ayia Napa',
      'location': 'Ayia Napa - Nissi Beach',
      'price': '€145 / night',
      'rating': '4.80',
      'imagePath': 'assets/images/szarvas.png',
      'description': 'Bright holiday home with private garden terrace only 3 minutes walk to crystal blue waters.',
      'type': 'accommodation',
    },
  ];

  List<Map<String, String>> get _filteredProperties {
    return _allProperties.where((item) {
      final query = _searchController.text.toLowerCase();
      final matchesQuery = item['title']!.toLowerCase().contains(query) ||
          item['location']!.toLowerCase().contains(query);
      final matchesRegion = _selectedRegion == 'All' || item['region'] == _selectedRegion;
      return matchesQuery && matchesRegion;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProperties;

    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        final isHu = locale == 'hu';

        return Scaffold(
          backgroundColor: darkBg,
          appBar: AppBar(
            backgroundColor: darkBg,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: mintGreenBorder, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              isHu ? 'Keresés Cipruson 🏝️' : 'Search in Cyprus 🏝️',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KERESŐMEZŐ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: turquoiseGlass,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: mintGreenBorder, width: 1.6),
                    boxShadow: [
                      BoxShadow(
                        color: mintGreenBorder.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: textDark, fontWeight: FontWeight.w800, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: isHu
                          ? 'Keresés apartman neve vagy városa szerint...'
                          : 'Search by property name or city...',
                      hintStyle: TextStyle(
                        color: textDark.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(Icons.search, color: deepBlueIcon),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: deepBlueIcon),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                ),
              ),

              // RÉGIÓ VÁLASZTÓ CHIP-EK
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: _regions.map((region) {
                    final isSelected = _selectedRegion == region;
                    final displayName = (region == 'All' && isHu) ? 'Összes' : region;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRegion = region;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? mintGreenBorder : turquoiseGlass,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.white : mintGreenBorder,
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: mintGreenBorder.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          displayName,
                          style: TextStyle(
                            color: deepBlueIcon,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // TALÁLATOK SZÁMA
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Text(
                  isHu ? 'Találatok (${filtered.length})' : 'Results (${filtered.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              // TALÁLATI LISTA
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          isHu ? 'Nincs találat a keresési feltételekre.' : 'No properties found.',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return _buildPropertyCard(item);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPropertyCard(Map<String, String> item) {
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
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: turquoiseGlass,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: mintGreenBorder, width: 1.6),
          boxShadow: [
            BoxShadow(
              color: mintGreenBorder.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.4),
          child: Row(
            children: [
              // KÉP
              SizedBox(
                width: 115,
                height: 115,
                child: Image.asset(
                  item['imagePath']!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: darkBg,
                    child: const Icon(Icons.villa_outlined, color: mintGreenBorder, size: 36),
                  ),
                ),
              ),

              // ADATOK
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['title']!,
                              style: const TextStyle(
                                color: textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: sunnyGold, size: 15),
                              const SizedBox(width: 3),
                              Text(
                                item['rating']!,
                                style: const TextStyle(
                                  color: textDark,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: deepBlueIcon, size: 14),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              item['location']!,
                              style: TextStyle(
                                color: textDark.withValues(alpha: 0.8),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: deepBlueIcon,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['price']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}