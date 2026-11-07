import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cyvesta/models/listing_model.dart';
import 'package:cyvesta/features/accommodation/presentation/accommodation_detail_page.dart';

class FirestoreCyprusMap extends StatefulWidget {
  final dynamic selectedRegion;

  const FirestoreCyprusMap({
    super.key,
    this.selectedRegion,
  });

  @override
  State<FirestoreCyprusMap> createState() => _FirestoreCyprusMapState();
}

class _FirestoreCyprusMapState extends State<FirestoreCyprusMap> {
ListingModel? _selectedListing;
Map<String, dynamic>? _selectedRawData;
BitmapDescriptor _customMarkerIcon = BitmapDescriptor.defaultMarker;

@override
void initState() {
super.initState();
_loadCustomMarker();
}

Future<void> _loadCustomMarker() async {
try {
final icon = await BitmapDescriptor.asset(
const ImageConfiguration(size: Size(36, 36)),
'assets/images/szarvas.png',
);
setState(() {
_customMarkerIcon = icon;
});
} catch (e) {
debugPrint("Nem sikerült betölteni az egyedi markert: $e");
}
}

CameraPosition _getInitialCameraPosition() {
final region = widget.selectedRegion?.toString().toLowerCase() ?? 'all';

LatLng target = const LatLng(35.1264, 33.4299); // Ciprus központ
double zoom = 9.0;

if (region.contains('paphos')) {
target = const LatLng(34.7754, 32.4245);
zoom = 11.5;
} else if (region.contains('kyrenia')) {
target = const LatLng(35.3375, 33.3172);
zoom = 11.5;
} else if (region.contains('limassol')) {
target = const LatLng(34.7071, 33.0226);
zoom = 11.5;
} else if (region.contains('larnaca')) {
target = const LatLng(34.9823, 33.6339);
zoom = 11.5;
} else if (region.contains('famagusta')) {
target = const LatLng(35.1264, 33.9423);
zoom = 11.5;
}

return CameraPosition(target: target, zoom: zoom);
}

@override
Widget build(BuildContext context) {
final regionText = widget.selectedRegion != null && widget.selectedRegion.toString() != 'all'
? widget.selectedRegion.toString().toUpperCase()
: '';

return Scaffold(
// KIJAVÍTVA: 'app:' helyett 'appBar:'
appBar: AppBar(
title: Text(widget.selectedRegion != null && widget.selectedRegion.toString() != 'all'
? 'CYVESTA - Régió: $regionText'
: 'CYVESTA - Összes Térkép'),
backgroundColor: const Color(0xFF072A40),
foregroundColor: Colors.white,
),
body: StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
.collection('listings')
.where('status', whereIn: ['approved', 'active'])
.snapshots(),
builder: (context, snapshot) {
if (snapshot.connectionState == ConnectionState.waiting) {
return const Center(child: CircularProgressIndicator());
}
if (snapshot.hasError) {
return Center(child: Text('Hiba történt: ${snapshot.error}'));
}

final docs = snapshot.data?.docs ?? [];

final List<Map<String, dynamic>> itemsWithModel = docs.map((doc) {
final data = doc.data() as Map<String, dynamic>;
final model = ListingModel(
id: doc.id,
title: data['title'] ?? 'Nincs név',
address: data['address'] ?? data['location'] ?? 'Ciprus',
imageUrl: (data['imageUrl'] ?? ((data['imageUrls'] is List && (data['imageUrls'] as List).isNotEmpty) ? (data['imageUrls'] as List).first : '')).toString(),
latitude: (data['latitude'] ?? 35.1264).toDouble(),
longitude: (data['longitude'] ?? 33.4299).toDouble(),
);
return {
'model': model,
'raw': data,
};
}).toList();

final List<Map<String, dynamic>> filteredItems = itemsWithModel.where((item) {
final ListingModel model = item['model'];
final Map<String, dynamic> raw = item['raw'];

if (widget.selectedRegion == null ||
widget.selectedRegion.toString().isEmpty ||
widget.selectedRegion.toString().toLowerCase() == 'all') {
return true;
}

final searchKey = widget.selectedRegion.toString().toLowerCase();
final addressMatch = model.address.toLowerCase().contains(searchKey);
final regionFieldMatch = (raw['region']?.toString().toLowerCase() ?? '').contains(searchKey);

return addressMatch || regionFieldMatch;
}).toList();

return Stack(
children: [
GoogleMap(
initialCameraPosition: _getInitialCameraPosition(),
markers: filteredItems.map((item) {
final ListingModel listing = item['model'];
return Marker(
markerId: MarkerId(listing.id),
position: LatLng(listing.latitude, listing.longitude),
icon: _customMarkerIcon,
onTap: () {
setState(() {
_selectedListing = listing;
_selectedRawData = item['raw'];
});
},
);
}).toSet(),
onTap: (position) {
setState(() {
_selectedListing = null;
_selectedRawData = null;
});
},
),
if (_selectedListing != null && _selectedRawData != null)
Positioned(
bottom: 20,
left: 20,
right: 20,
child: InkWell(
onTap: () {
final Map<String, dynamic> accommodationMap = {
'title': _selectedListing!.title,
'location': _selectedListing!.address,
'price': _selectedRawData!['price'] ?? 'Ár kérése',
'rating': _selectedRawData!['rating'] ?? '4.95',
'imagePath': _selectedListing!.imageUrl.isNotEmpty
? _selectedListing!.imageUrl
: 'assets/images/szarvas.png',
'category': _selectedRawData!['category'] ?? 'rent',
};
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => AccommodationDetailPage(
accommodationData: accommodationMap,
),
),
);
},
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
              errorBuilder: (c, e, s) => Container(
                width: 80,
                height: 80,
                color: const Color(0xFF072A40),
                child: const Icon(Icons.villa, color: Colors.white),
              ),
            )
                : Container(
              width: 80,
              height: 80,
              color: Colors.grey,
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedListing!.address,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF072A40),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _selectedRawData!['price'] ?? 'Ár kérése',
                    style: const TextStyle(
                      color: Color(0xFFFF9F1C),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              setState(() {
                _selectedListing = null;
                _selectedRawData = null;
              });
            },
          ),
        ],
      ),
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
