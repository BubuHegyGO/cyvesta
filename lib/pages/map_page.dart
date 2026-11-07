import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  // Alapértelmezett fókusz: Ciprus / Páfosz környéke
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(34.7754, 32.4245),
    zoom: 14.0,
  );

  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('shop_1'),
      position: LatLng(34.7770, 32.4200),
      infoWindow: InfoWindow(
        title: 'CYVESTA Market & Bolt',
        snippet: 'Helyi termékek és élelmiszerek a közelben',
      ),
    ),
    const Marker(
      markerId: MarkerId('service_1'),
      position: LatLng(34.7730, 32.4300),
      infoWindow: InfoWindow(
        title: 'Aphrodite Rent & Services',
        snippet: 'Autókölcsönzés és transzfer',
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CYVESTA Közeli Szolgáltatások'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialPosition,
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}