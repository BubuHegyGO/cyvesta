import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/app_language.dart';

class MapPage extends StatefulWidget {
  final String? initialCategory;

  const MapPage({super.key, this.initialCategory});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const Color darkBg = Color(0xFF061822);
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  final MapController _mapController = MapController();
  late String _selectedCategory;
  Map<String, dynamic>? _selectedPlace;

  // Kategóriák listája
  List<Map<String, dynamic>> _getCategories() => [
    {'id': 'all', 'name': AppLanguage.tr('all_regions'), 'icon': Icons.explore_rounded, 'color': mintGreenBorder},
    {'id': 'car_rental', 'name': AppLanguage.tr('serv_car_rental'), 'icon': Icons.directions_car_rounded, 'color': const Color(0xFFFF9F1C)},
    {'id': 'bike_rental', 'name': AppLanguage.tr('serv_bike_rental'), 'icon': Icons.two_wheeler_rounded, 'color': const Color(0xFF48CAE4)},
    {'id': 'pharmacy', 'name': AppLanguage.tr('serv_pharmacy'), 'icon': Icons.local_pharmacy_rounded, 'color': const Color(0xFF2EC4B6)},
    {'id': 'supermarket', 'name': AppLanguage.tr('serv_supermarket'), 'icon': Icons.shopping_cart_rounded, 'color': const Color(0xFFFFBF69)},
    {'id': 'nightlife', 'name': AppLanguage.tr('serv_nightlife'), 'icon': Icons.nightlife_rounded, 'color': const Color(0xFFE0AAFF)},
    {'id': 'bus_stop', 'name': AppLanguage.tr('serv_bus_stop'), 'icon': Icons.directions_bus_rounded, 'color': const Color(0xFF90E0EF)},
    {'id': 'atm', 'name': AppLanguage.tr('serv_atm'), 'icon': Icons.atm_rounded, 'color': const Color(0xFF80ED99)},
  ];

  // Ciprus környéki valós mintapontok (Paphos, Coral Bay, Limassol, Kyrenia)
  final List<Map<String, dynamic>> _places = [
    // Autókölcsönzők
    {
      'id': 'p1',
      'category': 'car_rental',
      'name': 'Island Car Rentals Paphos',
      'address': 'Tombs of the Kings Ave 42, Paphos',
      'lat': 34.7745,
      'lng': 32.4110,
      'distance': '350 m',
      'open': 'Open: 08:00 - 20:00',
      'phone': '+357 26 123 456',
    },
    {
      'id': 'p2',
      'category': 'car_rental',
      'name': 'Coral Bay Auto & Buggy Hire',
      'address': 'Coral Bay Rd 88, Pegeia',
      'lat': 34.8560,
      'lng': 32.3680,
      'distance': '1.2 km',
      'open': 'Open: 08:30 - 19:30',
      'phone': '+357 26 987 654',
    },
    // Kerékpár / Robogó
    {
      'id': 'p3',
      'category': 'bike_rental',
      'name': 'Cyprus E-Bike & Scooter Point',
      'address': 'Poseidonos Ave 15, Kato Paphos',
      'lat': 34.7562,
      'lng': 32.4180,
      'distance': '600 m',
      'open': 'Open: 09:00 - 21:00',
      'phone': '+357 99 112 233',
    },
    // Gyógyszertárak
    {
      'id': 'p4',
      'category': 'pharmacy',
      'name': 'Paphos Central Pharmacy (24/7 Duty)',
      'address': 'Apostolou Pavlou 24, Paphos',
      'lat': 34.7680,
      'lng': 32.4195,
      'distance': '450 m',
      'open': '24/7 Open (Night & Day)',
      'phone': '+357 26 889 900',
    },
    {
      'id': 'p5',
      'category': 'pharmacy',
      'name': 'Coral Bay Pharmacy Care',
      'address': 'Coral Bay Main Strip 12',
      'lat': 34.8540,
      'lng': 32.3650,
      'distance': '1.5 km',
      'open': 'Open: 08:00 - 22:00',
      'phone': '+357 26 443 322',
    },
    // Élelmiszerboltok
    {
      'id': 'p6',
      'category': 'supermarket',
      'name': 'Lidl Supermarket & Bakery',
      'address': 'Tombs of the Kings Rd, Paphos',
      'lat': 34.7810,
      'lng': 32.4080,
      'distance': '750 m',
      'open': 'Open: 07:00 - 21:30',
      'phone': '+357 800 94400',
    },
    {
      'id': 'p7',
      'category': 'supermarket',
      'name': 'Philippos Supermarket Coral Bay',
      'address': 'Agios Georgios Ave, Pegeia',
      'lat': 34.8580,
      'lng': 32.3710,
      'distance': '1.8 km',
      'open': 'Open: 07:30 - 22:00 (Free transfer)',
      'phone': '+357 26 622 262',
    },
    // Szórakozóhelyek & Bárok
    {
      'id': 'p8',
      'category': 'nightlife',
      'name': 'Amnesia Beach Club & Lounge',
      'address': 'Bar Street 18, Kato Paphos',
      'lat': 34.7570,
      'lng': 32.4160,
      'distance': '500 m',
      'open': 'Open: 20:00 - 04:00',
      'phone': '+357 99 778 899',
    },
    // Buszmegállók
    {
      'id': 'p9',
      'category': 'bus_stop',
      'name': 'Route 615 Bus Stop (Harbor - Coral Bay)',
      'address': 'Tombs of the Kings Main Stop',
      'lat': 34.7710,
      'lng': 32.4125,
      'distance': '120 m',
      'open': 'Buses every 10 mins • Ticket: €1.50',
      'phone': 'Cyprus Public Transport 1416',
    },
    {
      'id': 'p10',
      'category': 'bus_stop',
      'name': 'Kato Paphos Main Bus Station (Harbor Station)',
      'address': 'Kato Paphos Harbor Station',
      'lat': 34.7555,
      'lng': 32.4105,
      'distance': '900 m',
      'open': 'Airport & Intercity buses (612, 615, Intercity)',
      'phone': 'Cyprus Public Transport',
    },
    // ATM
    {
      'id': 'p11',
      'category': 'atm',
      'name': 'Bank of Cyprus ATM & Euronet',
      'address': 'Poseidonos Ave 8, Kato Paphos',
      'lat': 34.7585,
      'lng': 32.4170,
      'distance': '380 m',
      'open': '24/7 ATM Cash (EUR, GBP, USD)',
      'phone': '-',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'all';
  }

  Future<void> _launchMapsNavigation(double lat, double lng, String name) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _getCategories();

    // Szűrt lista a kiválasztott kategória alapján
    final filteredPlaces = _selectedCategory == 'all'
        ? _places
        : _places.where((p) => p['category'] == _selectedCategory).toList();

    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        return Scaffold(
          backgroundColor: darkBg,
          body: Stack(
            children: [
              // 1. TÉRKÉP ALAP - LATIN / ANGOL BETŰS VOYAGER CSEMPE
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(34.7680, 32.4150), // Ciprus / Paphos régió
                  initialZoom: 13.5,
                  minZoom: 8.0,
                  maxZoom: 19.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.cyvesta.app',
                  ),
                  MarkerLayer(
                    markers: filteredPlaces.map((place) {
                      final catInfo = categories.firstWhere(
                        (c) => c['id'] == place['category'],
                        orElse: () => {'icon': Icons.location_on, 'color': mintGreenBorder},
                      );
                      final isSelected = _selectedPlace?['id'] == place['id'];

                      return Marker(
                        point: LatLng(place['lat'], place['lng']),
                        width: isSelected ? 50 : 42,
                        height: isSelected ? 50 : 42,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPlace = place;
                            });
                            _mapController.move(LatLng(place['lat'], place['lng']), 15.0);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            decoration: BoxDecoration(
                              color: isSelected ? sunnyGold : deepBlueIcon,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : (catInfo['color'] as Color),
                                width: isSelected ? 3 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              catInfo['icon'] as IconData,
                              color: isSelected ? textDark : (catInfo['color'] as Color),
                              size: isSelected ? 26 : 22,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // 2. FELSŐ KATEGÓRIAVÁLASZTÓ ÉS VISSZA GOMB
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: deepBlueIcon,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, color: mintGreenBorder, size: 18),
                              onPressed: () => Navigator.maybePop(context),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: deepBlueIcon.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: mintGreenBorder, width: 1.4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.near_me_rounded, color: sunnyGold, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      AppLanguage.tr('nearby_services_title'),
                                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // HORIZONTÁLIS KATEGÓRIAVÁLTÓ CSÚSZKA
                      SizedBox(
                        height: 38,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            final isActive = _selectedCategory == cat['id'];

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = cat['id'];
                                  _selectedPlace = null;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isActive ? sunnyGold : deepBlueIcon.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isActive ? Colors.white : mintGreenBorder.withValues(alpha: 0.7),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      cat['icon'] as IconData,
                                      color: isActive ? textDark : (cat['color'] as Color),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      cat['name'] as String,
                                      style: TextStyle(
                                        color: isActive ? textDark : Colors.white,
                                        fontSize: 12,
                                        fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                                      ),
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
              ),

              // 3. KIVÁLASZTOTT HELY INFORMÁCIÓS KÁRTYA (ALUL)
              if (_selectedPlace != null)
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: turquoiseGlass,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: mintGreenBorder, width: 1.6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedPlace!['name'],
                                    style: const TextStyle(color: textDark, fontSize: 15.5, fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedPlace!['address'],
                                    style: TextStyle(color: textDark.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: deepBlueIcon,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _selectedPlace!['distance'],
                                style: const TextStyle(color: sunnyGold, fontSize: 11, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, color: deepBlueIcon, size: 15),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                _selectedPlace!['open'],
                                style: const TextStyle(color: textDark, fontSize: 11.5, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: deepBlueIcon,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: const Icon(Icons.directions_rounded, color: sunnyGold, size: 18),
                                  label: Text(
                                    locale == 'hu' ? 'Útvonaltervezés (GPS)' : 'Get Directions (GPS)',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () => _launchMapsNavigation(
                                    _selectedPlace!['lat'],
                                    _selectedPlace!['lng'],
                                    _selectedPlace!['name'],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              style: IconButton.styleFrom(backgroundColor: deepBlueIcon),
                              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                              onPressed: () => setState(() => _selectedPlace = null),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}