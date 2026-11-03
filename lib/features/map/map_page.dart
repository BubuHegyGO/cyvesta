import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  final LatLng? initialTarget; // Opcionális célkoordináta a régióválasztáshoz
  final String? regionName;     // Opcionális régiónév a címsorhoz

  const MapPage({super.key, this.initialTarget, this.regionName});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _controller;

  // Alapértelmezett fókusz: Ciprus / Páfosz, ha nincs megadva más
  static const LatLng _defaultLocation = LatLng(34.7754, 32.4245);

  late final CameraPosition _initialPosition;
  late LatLng _currentTarget;

  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('shop_1'),
      position: LatLng(34.7770, 32.4200),
      infoWindow: InfoWindow(
        title: 'CYVESTA Market & Bolt',
        snippet: 'Helyi termékek és élelmiszerek',
      ),
    ),
  };

  @override
  void initState() {
    super.initState();
    _currentTarget = widget.initialTarget ?? _defaultLocation;
    _initialPosition = CameraPosition(
      target: _currentTarget,
      zoom: 13.0,
    );
  }

  // Navigáció indítása a külső Google Maps alkalmazásban
  Future<void> _openNavigation() async {
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${_currentTarget.latitude},${_currentTarget.longitude}',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nem sikerült megnyitni a navigációt! ⚠️')),
        );
      }
    }
  }

  // Google Street View (Utcakép) megnyitása
  Future<void> _openStreetView() async {
    final streetViewUrl = Uri.parse(
      'google.streetview:cbll=${_currentTarget.latitude},${_currentTarget.longitude}',
    );
    final fallbackUrl = Uri.parse(
      'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=${_currentTarget.latitude},${_currentTarget.longitude}',
    );

    if (await canLaunchUrl(streetViewUrl)) {
      await launchUrl(streetViewUrl);
    } else if (await canLaunchUrl(fallbackUrl)) {
      await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Az utcakép (Street View) nem érhető el ezen az eszközen. ⚠️')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.regionName != null
        ? 'CYVESTA Térkép - ${widget.regionName}'
        : 'CYVESTA Térkép';

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              if (widget.initialTarget != null) {
                _controller.animateCamera(
                  CameraUpdate.newLatLngZoom(widget.initialTarget!, 13.0),
                );
              }
            },
            onCameraMove: (position) {
              _currentTarget = position.target; // Frissítjük az aktuális fókuszpontot mozgatáskor
            },
          ),

          // Lebegő gombok a jobb alsó sarokban (Navigáció és Utcakép)
          Positioned(
            bottom: 24,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Utcakép Gomb
                FloatingActionButton(
                  heroTag: 'streetViewBtn',
                  backgroundColor: const Color(0xFFFF9F1C),
                  foregroundColor: const Color(0xFF0F172A),
                  tooltip: 'Utcakép (Street View)',
                  onPressed: _openStreetView,
                  child: const Icon(Icons.streetview_rounded, size: 26),
                ),
                const SizedBox(height: 12),
                // Navigáció Gomb
                FloatingActionButton.extended(
                  heroTag: 'navBtn',
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.navigation_rounded, color: Color(0xFF99FF99)),
                  label: const Text(
                    'Navigáció',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onPressed: _openNavigation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}