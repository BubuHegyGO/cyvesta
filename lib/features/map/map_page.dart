import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const Color accent = Color(0xFF8BC541);

  late GoogleMapController _mapController;

  // Kezdőpozíció: Mátraháza
  static const CameraPosition _kematra = CameraPosition(
    target: LatLng(47.8828, 19.9723),
    zoom: 11.5,
  );

  final Set<Marker> _markers = {
    Marker(
      markerId: const MarkerId('matra_1'),
      position: const LatLng(47.8828, 19.9723),
      infoWindow: const InfoWindow(
        title: 'Mátrai Panoráma Vendégház',
        snippet: '35.000 Ft / éj • Mátraháza',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ),
    Marker(
      markerId: const MarkerId('bukk_1'),
      position: const LatLng(48.0617, 20.4789),
      infoWindow: const InfoWindow(
        title: 'Bükki Faház & Szauna',
        snippet: '28.000 Ft / éj • Szilvásvárad',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Térképes Kereső 🗺️',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // HIVATALOS GOOGLE MAPS UTCATÉRKÉP
          GoogleMap(
            initialCameraPosition: _kematra,
            mapType: MapType.normal,
            markers: _markers,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),

          // KERESŐ / INFÓ KÁRTYA A TÉRKÉP TETEJÉN
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.location_on_rounded, color: accent),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '32 szabad szállás a térképen',
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  Icon(Icons.tune_rounded, color: Colors.black54),
                ],
              ),
            ),
          ),

          // ZOOM GOMBOK
          Positioned(
            bottom: 20,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  child: const Icon(Icons.add),
                  onPressed: () => _mapController.animateCamera(CameraUpdate.zoomIn()),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  child: const Icon(Icons.remove),
                  onPressed: () => _mapController.animateCamera(CameraUpdate.zoomOut()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}