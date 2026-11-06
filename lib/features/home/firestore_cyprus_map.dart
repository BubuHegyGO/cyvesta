import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cyvesta/models/listing_model.dart';

class FirestoreCyprusMap extends StatefulWidget {
  const FirestoreCyprusMap({super.key});

  @override
  State<FirestoreCyprusMap> createState() => _FirestoreCyprusMapState();
}

class _FirestoreCyprusMapState extends State<FirestoreCyprusMap> {
  ListingModel? _selectedListing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      app: AppBar(
        title: const Text('CYVESTA - Élő Hirdetések a Térképen'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Itt hallgatjuk a Firestore 'listings' kollekcióját
        stream: FirebaseFirestore.instance.collection('listings').snapshots(),
        builder: (context, snapshot) {
          // 1. Ha még töltődik az adat
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Ha hiba történt
          if (snapshot.hasError) {
            return Center(child: Text('Hiba történt: ${snapshot.error}'));
          }

          // 3. Adatok feldolgozása Listává
          final docs = snapshot.data?.docs ?? [];

          List<ListingModel> listings = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ListingModel(
              id: doc.id,
              title: data['title'] ?? 'Nincs név',
              address: data['address'] ?? 'Ciprus',
              imageUrl: data['imageUrl'] ?? '',
              latitude: (data['latitude'] ?? 35.1264).toDouble(),
              longitude: (data['longitude'] ?? 33.4299).toDouble(),
            );
          }).toList();

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(35.1264, 33.4299), // Ciprus központ
                  zoom: 9.0,
                ),
                markers: listings.map((listing) {
                  return Marker(
                    markerId: MarkerId(listing.id),
                    position: LatLng(listing.latitude, listing.longitude),
                    onTap: () {
                      setState(() {
                        _selectedListing = listing;
                      });
                    },
                  );
                }).toSet(),
                onTap: (position) {
                  setState(() {
                    _selectedListing = null; // Eltünteti a kártyát, ha üres helyre kattintanak
                  });
                },
              ),

              // Alsó kártya a kiválasztott hirdetéshez
              if (_selectedListing != null)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: _selectedListing!.imageUrl.isNotEmpty
                                ? Image.network(
                              _selectedListing!.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                                : Container(width: 80, height: 80, color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _selectedListing!.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedListing!.address,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() {
                                _selectedListing = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}