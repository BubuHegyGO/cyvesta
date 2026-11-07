import 'package:flutter/material.dart';
import '../../../../core/services/ical_service.dart';

/// Felszereltség / paraméter-kulcsok és magyar címkék (a Firestore-ban a kulcs tárolódik).
class ListingAmenities {
  static const Map<String, String> rent = {
    'wifi': 'WiFi',
    'ac': 'Klíma',
    'heating': 'Fűtés',
    'kitchen': 'Felszerelt konyha',
    'washer': 'Mosógép',
    'tv': 'TV',
    'pool': 'Medence',
    'parking': 'Parkoló',
    'balcony': 'Erkély / terasz',
    'seaview': 'Tengerre néző',
    'bbq': 'Grill / BBQ',
    'elevator': 'Lift',
    'pets': 'Háziállat engedélyezett',
    'smoking': 'Dohányzás engedélyezett',
    'beachnear': 'Közel a tengerparthoz',
    'linen': 'Ágynemű / törölköző',
  };

  static const Map<String, String> sale = {
    'pool': 'Medence',
    'garden': 'Kert',
    'seaview': 'Tengerre néző',
    'ac': 'Klíma',
    'elevator': 'Lift',
    'balcony': 'Erkély / terasz',
    'parking': 'Parkoló / garázs',
    'furnished': 'Bútorozott',
    'solar': 'Napelem / napkollektor',
    'storage': 'Tárolóhelyiség',
    'security': 'Biztonsági rendszer',
    'fireplace': 'Kandalló',
  };

  static const Map<String, String> conditions = {
    'new': 'Új építésű',
    'renovated': 'Felújított',
    'good': 'Jó állapotú',
    'needsWork': 'Felújítandó',
  };
}

/// A varázsló "Jellemzők" lépésének adatai.
class ListingDetails {
  int guests = 2;
  int bedrooms = 1;
  int beds = 1;
  int bathrooms = 1;
  int parkingSpaces = 0;
  bool titleDeed = false;
  String condition = 'good';
  final Set<String> amenities = <String>{};

  final TextEditingController areaCtrl = TextEditingController();
  final TextEditingController plotCtrl = TextEditingController();
  final TextEditingController floorCtrl = TextEditingController();
  final TextEditingController yearCtrl = TextEditingController();
  final TextEditingController icalCtrl = TextEditingController();

  /// Egy mentett `details` térkép betöltése szerkesztéshez.
  void loadFrom(Map<String, dynamic> m) {
    int? i(dynamic v) => v is num ? v.toInt() : null;
    String t(dynamic v) => v is num ? (v == v.roundToDouble() ? v.toInt().toString() : v.toString()) : '';
    guests = i(m['guests']) ?? guests;
    bedrooms = i(m['bedrooms']) ?? bedrooms;
    beds = i(m['beds']) ?? beds;
    bathrooms = i(m['bathrooms']) ?? bathrooms;
    parkingSpaces = i(m['parkingSpaces']) ?? parkingSpaces;
    titleDeed = m['titleDeed'] == true;
    final c = m['condition']?.toString();
    if (c != null && ListingAmenities.conditions.containsKey(c)) condition = c;
    areaCtrl.text = t(m['areaM2']);
    plotCtrl.text = t(m['plotM2']);
    floorCtrl.text = t(m['floor']);
    yearCtrl.text = t(m['yearBuilt']);
    amenities
      ..clear()
      ..addAll(m['amenities'] is List ? (m['amenities'] as List).map((e) => e.toString()) : const <String>[]);
  }

  double? get area => double.tryParse(areaCtrl.text.trim().replaceAll(',', '.'));

  void dispose() {
    areaCtrl.dispose();
    plotCtrl.dispose();
    floorCtrl.dispose();
    yearCtrl.dispose();
    icalCtrl.dispose();
  }

  String? validate({required bool isRent}) {
    final a = area;
    if (!isRent && (a == null || a <= 0)) return 'Add meg az ingatlan alapterületét (m²).';
    if (a != null && (a < 0 || a > 100000)) return 'Az alapterület értéke nem megfelelő.';
    if (isRent && guests < 1) return 'Legalább 1 vendég férőhely szükséges.';
    final y = int.tryParse(yearCtrl.text.trim());
    if (isRent && icalCtrl.text.trim().isNotEmpty && ICalService.normalizeUrl(icalCtrl.text) == null) {
      return 'Az iCal link érvénytelen. https:// (vagy webcal://) címet adj meg.';
    }
    if (yearCtrl.text.trim().isNotEmpty && (y == null || y < 1800 || y > DateTime.now().year + 5)) {
      return 'Az építés éve nem megfelelő.';
    }
    return null;
  }

  /// Firestore-ba mentendő térkép (csak a kitöltött / releváns mezők).
  Map<String, dynamic> toMap({required bool isRent}) {
    final allowed = (isRent ? ListingAmenities.rent : ListingAmenities.sale).keys.toSet();
    final map = <String, dynamic>{
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'amenities': amenities.where(allowed.contains).toList()..sort(),
    };
    final a = area;
    if (a != null && a > 0) map['areaM2'] = a;
    if (isRent) {
      map['guests'] = guests;
      map['beds'] = beds;
    } else {
      final plot = double.tryParse(plotCtrl.text.trim().replaceAll(',', '.'));
      if (plot != null && plot > 0) map['plotM2'] = plot;
      final floor = int.tryParse(floorCtrl.text.trim());
      if (floor != null) map['floor'] = floor;
      final year = int.tryParse(yearCtrl.text.trim());
      if (year != null) map['yearBuilt'] = year;
      map['condition'] = condition;
      map['titleDeed'] = titleDeed;
      map['parkingSpaces'] = parkingSpaces;
    }
    return map;
  }
}

class ListingDetailsForm extends StatefulWidget {
  final ListingDetails details;
  final bool isRent;

  const ListingDetailsForm({super.key, required this.details, required this.isRent});

  @override
  State<ListingDetailsForm> createState() => _ListingDetailsFormState();
}

class _ListingDetailsFormState extends State<ListingDetailsForm> {
  static const Color _field = Color(0xFF093753);
  static const Color _mint = Color(0xFF99FF99);

  ListingDetails get d => widget.details;

  Widget _counter(String label, IconData icon, int value, void Function(int) onChanged, {int min = 0, int max = 30}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: _field, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: _mint, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14))),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
            onPressed: value > min ? () => setState(() => onChanged(value - 1)) : null,
          ),
          SizedBox(
            width: 28,
            child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFF9F1C)),
            onPressed: value < max ? () => setState(() => onChanged(value + 1)) : null,
          ),
        ],
      ),
    );
  }

  Widget _numberField(TextEditingController c, String label, {bool decimal = true, bool signed = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal, signed: signed),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: _field,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      );

  @override
  Widget build(BuildContext context) {
    final amenityMap = widget.isRent ? ListingAmenities.rent : ListingAmenities.sale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isRent ? 'Szálláshely jellemzői' : 'Ingatlan paraméterei',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (widget.isRent)
          _counter('Maximum vendég', Icons.groups_rounded, d.guests, (v) => d.guests = v, min: 1, max: 30),
        _counter('Hálószobák', Icons.meeting_room_rounded, d.bedrooms, (v) => d.bedrooms = v),
        if (widget.isRent) _counter('Ágyak', Icons.bed_rounded, d.beds, (v) => d.beds = v, min: 1),
        _counter('Fürdőszobák', Icons.bathtub_rounded, d.bathrooms, (v) => d.bathrooms = v),
        if (!widget.isRent) _counter('Parkolóhelyek', Icons.local_parking_rounded, d.parkingSpaces, (v) => d.parkingSpaces = v),
        _numberField(d.areaCtrl, widget.isRent ? 'Alapterület (m²) – nem kötelező' : 'Alapterület (m²) *'),
        if (!widget.isRent) ...[
          _numberField(d.plotCtrl, 'Telek mérete (m²) – nem kötelező'),
          _numberField(d.floorCtrl, 'Emelet (0 = földszint) – nem kötelező', decimal: false, signed: true),
          _numberField(d.yearCtrl, 'Építés éve – nem kötelező', decimal: false),
          _title('Állapot'),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: ListingAmenities.conditions.entries
                .map((e) => ChoiceChip(
                      label: Text(e.value),
                      selected: d.condition == e.key,
                      onSelected: (_) => setState(() => d.condition = e.key),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Title deed (tulajdoni lap) rendelkezésre áll', style: TextStyle(color: Colors.white, fontSize: 14)),
            value: d.titleDeed,
            onChanged: (v) => setState(() => d.titleDeed = v),
          ),
        ],
        if (widget.isRent) ...[
          _title('Foglalási naptár szinkronizálása (iCal)'),
          TextField(
            controller: d.icalCtrl,
            keyboardType: TextInputType.url,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'iCal link (Airbnb / Booking.com / VRBO) – nem kötelező',
              labelStyle: const TextStyle(color: Colors.white70),
              helperText: 'Airbnb: Naptár → Elérhetőség → Naptár szinkronizálása → Naptár exportálása. A foglalt napok így nem lesznek foglalhatók.',
              helperMaxLines: 3,
              helperStyle: const TextStyle(color: Colors.white54, fontSize: 11),
              filled: true,
              fillColor: _field,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
        ],
        _title(widget.isRent ? 'Felszereltség' : 'Extrák'),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: amenityMap.entries
              .map((e) => FilterChip(
                    label: Text(e.value),
                    selected: d.amenities.contains(e.key),
                    onSelected: (sel) => setState(() {
                      if (sel) {
                        d.amenities.add(e.key);
                      } else {
                        d.amenities.remove(e.key);
                      }
                    }),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
