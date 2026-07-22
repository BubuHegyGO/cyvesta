import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/services/data_service.dart';
import '../accommodation/presentation/accommodation_detail_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const Color bgColor = Color(0xFF07130A);
  static const Color accent = Color(0xFF8BC541);

  final DataService _dataService = DataService();
  final MapController _mapController = MapController();
  Map<String, dynamic>? _selectedItem;

  final LatLng _initialCenter = const LatLng(47.8723, 20.0031);

  @override
  Widget build(BuildContext context) {
    final accommodations = _dataService.getAccommodations();
    final experiences = _dataService.getExperiences();
    final allItems = [...accommodations, ...experiences];

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // VILÁGOS OPENSTREETMAP TÉRKÉP RÉTEG (Retina beállítással)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 10.0,
              minZoom: 7.0,
              maxZoom: 18.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedItem = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'hu.hegygo.app',
                retinaMode: RetinaMode.isHighDensity(context),
              ),

              // PIN-EK RÉTEGE
              MarkerLayer(
                markers: allItems.map((item) {
                  final isSelected = _selectedItem?['id'] == item['id'];
                  final lat = item['latitude'] as double? ?? 47.87;
                  final lng = item['longitude'] as double? ?? 20.00;

                  return Marker(
                    point: LatLng(lat, lng),
                    width: 110,
                    height: 45,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedItem = item;
                        });
                        _mapController.move(LatLng(lat, lng), 12.0);
                      },
                      child: AnimatedScale(
                        scale: isSelected ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? accent : const Color(0xFF0D2113),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: accent, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: isSelected ? 12 : 6,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: isSelected ? Colors.black : accent,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  item['price']?.split(' ')[0] ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // FELSŐ CÍMSOR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Icon(Icons.map_rounded, color: accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Text(
                      'Mátra & Bükk Térkép',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ALSÓ KIJELÖLT KÁRTYA (Bottom Sheet)
          if (_selectedItem != null)
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D2113),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccommodationDetailPage(
                          accommodationData: _selectedItem!,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          _selectedItem!['image'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedItem!['category'] ?? '',
                              style: const TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedItem!['title'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedItem!['location'] ?? '',
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _selectedItem!['price'] ?? '',
                              style: const TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white54),
                        onPressed: () {
                          setState(() {
                            _selectedItem = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}