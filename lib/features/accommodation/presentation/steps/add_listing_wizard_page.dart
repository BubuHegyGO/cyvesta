import 'dart:io';
import 'package:flutter/foundation.dart' show Factory;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/widgets/cyvesta_scaffold.dart';
import '../../../../core/services/listing_duplicate_service.dart';
import '../../../../core/services/auth_state.dart';
import '../../../../core/services/ical_service.dart';
import 'listing_details_form.dart';
import '../../../../core/widgets/auth_dialogs.dart';

class AddListingWizardPage extends StatefulWidget {
  const AddListingWizardPage({super.key});

  @override
  State<AddListingWizardPage> createState() => _AddListingWizardPageState();
}

class _AddListingWizardPageState extends State<AddListingWizardPage> {
  static const int _totalSteps = 8;
  static const int _maxPhotos = 10;

  int _currentStep = 0;
  bool _isSubmitting = false;
  String _uploadStatus = '';

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _photos = [];
  final List<Reference> _uploadedRefs = [];
  LatLng? _pickedLocation;

  // Adatok a hirdetéshez
  String _selectedCategory = 'Ingatlan / Eladó-Kiadó';
  final ListingDetails _details = ListingDetails();
  String _listingType = 'rent'; // 'rent' | 'sale'
  String _priceUnit = 'night'; // 'night' | 'month' (csak kiadásnál)

  bool get _isPropertyCategory => _selectedCategory == 'Ingatlan / Eladó-Kiadó';
  bool get _isLodgingCategory => _selectedCategory == 'Szálláshely / Hotel';
  bool get _hasListingType => _isPropertyCategory || _isLodgingCategory;
  bool get _effectiveIsRent => _isLodgingCategory || (_isPropertyCategory && _listingType == 'rent');
  final TextEditingController _customCategoryController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _addressController = TextEditingController(); // Új mező a pontos címhez (duplikáció szűréshez)
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Feltöltött képek listája (itt bővíthető képfeltöltéssel)
  final List<String> _uploadedImageUrls = [];

  final List<String> _predefinedCategories = [
    'Ingatlan / Eladó-Kiadó',
    'Szálláshely / Hotel',
    'Autókölcsönzés / Transzfer',
    'Egyéb (Saját kategória megadása)',
  ];

  @override
  void dispose() {
    _customCategoryController.dispose();
    _titleController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _details.dispose();
    super.dispose();
  }

  /// Nemzetközi formátumra hozza a telefonszámot (+35799123456); érvénytelen esetén null.
  String? _normalizedPhone() {
    var p = _phoneController.text.trim().replaceAll(RegExp(r'[\s\-().]'), '');
    if (p.startsWith('00')) p = '+${p.substring(2)}';
    return RegExp(r'^\+[0-9]{8,15}$').hasMatch(p) ? p : null;
  }

  double? _parsePrice() => double.tryParse(_priceController.text.trim().replaceAll(',', '.'));

  String? _validateStep(int step) {
    switch (step) {
      case 0:
        if (_selectedCategory == 'Egyéb (Saját kategória megadása)' && _customCategoryController.text.trim().isEmpty) {
          return 'Add meg a saját kategóriádat.';
        }
        return null;
      case 1:
        if (_titleController.text.trim().isEmpty) return 'Add meg a hirdetés címét.';
        if (_addressController.text.trim().isEmpty) return 'Add meg a pontos címet.';
        if (_normalizedPhone() == null) return 'Add meg a telefonszámot nemzetközi formátumban (pl. +35799123456).';
        return null;
      case 2:
        final price = _parsePrice();
        if (price == null || price < 0) return 'Adj meg érvényes árat (szám, pl. 1200).';
        return null;
      case 3:
        if (!_hasListingType) return null;
        return _details.validate(isRent: _effectiveIsRent);
      case 5:
        if (_pickedLocation == null) return 'Jelöld meg a helyszínt a térképen.';
        return null;
      case 6:
        if (_photos.isEmpty) return 'Tölts fel legalább 1 fényképet.';
        return null;
      default:
        return null;
    }
  }

  Future<void> _pickPhotos() async {
    final remaining = _maxPhotos - _photos.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 10 db fotó tölthető fel!'), backgroundColor: Colors.orange),
      );
      return;
    }
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 80, maxWidth: 1600, maxHeight: 1600);
      if (picked.isEmpty || !mounted) return;
      setState(() => _photos.addAll(picked.take(remaining)));
      if (picked.length > remaining) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Elérted a maximum 10 db-os fotókorlátot.'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('A fotók kiválasztása nem sikerült: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  /// Feltölti a kiválasztott fotókat a Firebase Storage-ba, és visszaadja a letöltési címeket.
  /// Hiba esetén a már feltöltött fájlokat törli.
  Future<List<String>> _uploadPhotos(String uid) async {
    final storage = FirebaseStorage.instance;
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final urls = <String>[];
    _uploadedRefs.clear();

    try {
      for (var i = 0; i < _photos.length; i++) {
        if (mounted) {
          setState(() => _uploadStatus = 'Fotók feltöltése (${i + 1}/${_photos.length})...');
        }
        final path = _photos[i].path;
        final dot = path.lastIndexOf('.');
        var ext = dot >= 0 ? path.substring(dot + 1).toLowerCase() : 'jpg';
        if (!const ['jpg', 'jpeg', 'png', 'webp', 'heic'].contains(ext)) ext = 'jpg';
        final contentType = (ext == 'jpg' || ext == 'jpeg') ? 'image/jpeg' : 'image/$ext';

        final ref = storage.ref('listings/$uid/${stamp}_$i.$ext');
        await ref.putFile(File(path), SettableMetadata(contentType: contentType));
        _uploadedRefs.add(ref);
        urls.add(await ref.getDownloadURL());
      }
    } catch (e) {
      for (final r in _uploadedRefs) {
        try {
          await r.delete();
        } catch (_) {}
      }
      _uploadedRefs.clear();
      rethrow;
    }
    return urls;
  }

  void _nextStep() {
    final error = _validateStep(_currentStep);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error ⚠️'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
        if (_currentStep == 3 && !_hasListingType) _currentStep++; // nincs paraméter-lépés ehhez a kategóriához
      });
    } else {
      // Utolsó lépés - Duplikáció ellenőrzés és Mentés
      _submitListing();
    }
  }

  Future<void> _submitListing() async {
    final uid = AuthState.currentUserId;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hirdetés feladásához be kell jelentkezned! ⚠️')),
      );
      return;
    }

    // Hirdetést csak jóváhagyott céges partner vagy admin adhat fel.
    await AuthState.refreshRoles();
    if (!mounted) return;

    final isAdmin = AuthState.isAdmin.value;
    if (!isAdmin && !AuthState.isPartner.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hirdetést csak jóváhagyott céges partner adhat fel. ⚠️')),
      );
      return;
    }

    // Jelszavas partner fiókkal csak megerősített e-mail címmel lehet hirdetést feladni (az adminra ez nem vonatkozik).
    if (!isAdmin && !await ensureEmailVerified(context)) return;
    if (!mounted) return;

    final address = _addressController.text.trim();

    setState(() {
      _isSubmitting = true;
    });

    // 1. Duplikáció ellenőrzés futtatása a ListingDuplicateService segítségével
    final duplicateCheck = await ListingDuplicateService.checkDuplicate(
      address: address,
      imageUrls: _uploadedImageUrls,
    );

    if (duplicateCheck['isDuplicate'] == true) {
      setState(() {
        _isSubmitting = false;
      });

      // Ha duplikációt talál, megállítjuk és figyelmeztetést dobunk
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF072A40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF99FF99), width: 1.4),
            ),
            title: const Text('Hirdetési ütközés! ⚠️', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: Text(
              duplicateCheck['reason'] ?? 'Ez a hirdetés már létezik a rendszerben.',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9F1C),
                  foregroundColor: const Color(0xFF0F172A),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Rendben', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
      return; // Megszakítjuk a mentést!
    }

    // 2. Ha minden tiszta, mentjük a Firestore-ba
    try {
      final category = _selectedCategory == 'Egyéb (Saját kategória megadása)'
          ? _customCategoryController.text.trim()
          : _selectedCategory;

      // Fotók feltöltése a Storage-ba (a letöltési címek kerülnek a hirdetésbe)
      String contactName = 'CYVESTA';
      if (!isAdmin) {
        try {
          final pSnap = await FirebaseFirestore.instance.collection('partners').doc(uid).get();
          final n = pSnap.data()?['companyName']?.toString().trim() ?? '';
          if (n.isNotEmpty) contactName = n;
        } catch (_) {}
      }
      final icalUrl = _effectiveIsRent && _hasListingType ? ICalService.normalizeUrl(_details.icalCtrl.text) : null;

      final imageUrls = await _uploadPhotos(uid);
      final location = _pickedLocation;

      await FirebaseFirestore.instance.collection('listings').add({
        'partnerId': uid,
        'category': category,
        'title': _titleController.text.trim(),
        'address': address,
        'addressNormalized': ListingDuplicateService.normalizeAddress(address),
        'price': _parsePrice() ?? 0.0,
        if (_hasListingType) 'listingType': _effectiveIsRent ? 'rent' : 'sale',
        if (_hasListingType && _effectiveIsRent) 'priceUnit': _priceUnit,
        'contactPhone': _normalizedPhone(),
        'contactName': contactName,
        if (icalUrl != null) 'icalUrl': icalUrl,
        if (_hasListingType) 'details': _details.toMap(isRent: _effectiveIsRent),
        if (location != null) 'latitude': location.latitude,
        if (location != null) 'longitude': location.longitude,
        'description': _descriptionController.text.trim(),
        'imageUrls': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
        'status': isAdmin ? 'approved' : 'pending', // Az admin hirdetése azonnal élesedik, a többi moderálásra vár
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hirdetés sikeresen elküldve moderálásra! ✅'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // Ha a hirdetés mentése nem sikerült, a már feltöltött fotókat is töröljük.
      for (final r in _uploadedRefs) {
        try {
          await r.delete();
        } catch (_) {}
      }
      _uploadedRefs.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hiba a mentés során: $e ❌'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _uploadStatus = '';
        });
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        if (_currentStep == 3 && !_hasListingType) _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CyvestaScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Címsor és lépésjelző
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hirdetés feladása (${_currentStep + 1}/$_totalSteps)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Tartalom lépésenként
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildCurrentStepContent(),
              ),
            ),

            if (_isSubmitting && _uploadStatus.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(_uploadStatus, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ),

            // Navigációs gombok (Előző / Következő)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: _isSubmitting ? null : _previousStep,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF99FF99)),
                    ),
                    child: const Text('Vissza', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9F1C),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : Text(
                      _currentStep == _totalSteps - 1 ? 'Küldés' : 'Következő',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStep() {
    final picked = _pickedLocation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Helyszín a térképen', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text(
          'Koppints a térképre, hogy megjelöld az ingatlan vagy a vállalkozás pontos helyét.',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 380,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: picked ?? const LatLng(35.0, 33.2),
                zoom: picked != null ? 14 : 8,
              ),
              markers: picked == null
                  ? <Marker>{}
                  : <Marker>{Marker(markerId: const MarkerId('listing'), position: picked)},
              onTap: (point) => setState(() => _pickedLocation = point),
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
              },
              zoomControlsEnabled: true,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          picked == null
              ? 'Még nincs megjelölt helyszín.'
              : 'Kijelölve: ${picked.latitude.toStringAsFixed(5)}, ${picked.longitude.toStringAsFixed(5)}',
          style: TextStyle(color: picked == null ? Colors.orangeAccent : const Color(0xFF99FF99), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildPhotosStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fényképek feltöltése (max. 10 db)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Kiválasztva: ${_photos.length} / $_maxPhotos', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _photos.length + (_photos.length < _maxPhotos ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _photos.length) {
              return GestureDetector(
                onTap: _pickPhotos,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF093753),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF99FF99), width: 1.5),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, color: Color(0xFFFF9F1C), size: 30),
                      SizedBox(height: 4),
                      Text('Hozzáadás', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              );
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(_photos[index].path), fit: BoxFit.cover),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removePhoto(index),
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
      // 1. Lépés: Kategória kiválasztása
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Válasszon kategóriát vagy adjon meg sajátot:',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF093753),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF093753),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              initialValue: _selectedCategory,
              items: _predefinedCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_isPropertyCategory) ...[
              const Text('Mit hirdet?', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: [
                  ChoiceChip(
                    label: const Text('Kiadó (bérlet)'),
                    selected: _listingType == 'rent',
                    onSelected: (_) => setState(() => _listingType = 'rent'),
                  ),
                  ChoiceChip(
                    label: const Text('Eladó'),
                    selected: _listingType == 'sale',
                    onSelected: (_) => setState(() => _listingType = 'sale'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (_hasListingType && _effectiveIsRent) ...[
              const Text('Az ár időegysége:', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: [
                  ChoiceChip(
                    label: const Text('€ / éj'),
                    selected: _priceUnit == 'night',
                    onSelected: (_) => setState(() => _priceUnit = 'night'),
                  ),
                  ChoiceChip(
                    label: const Text('€ / hó'),
                    selected: _priceUnit == 'month',
                    onSelected: (_) => setState(() => _priceUnit = 'month'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (_selectedCategory == 'Egyéb (Saját kategória megadása)') ...[
              TextField(
                controller: _customCategoryController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Írja be a saját kategóriáját (pl. Fagyizó, Fodrász...)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF093753),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        );

      case 1:
      // 2. Lépés: Cím és Pontos Cím (Duplikáció szűréshez)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hirdetés címe', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Pl. Luxus apartman Paphosban',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF093753),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Pontos Cím / Lokáció (Csalásvédelemhez)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Pl. Poseidonos Avenue 12, Paphos',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF093753),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Kapcsolattartó telefonszám / WhatsApp', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Nemzetközi formátumban, ezen a számon érhetnek el az érdeklődők.', style: TextStyle(color: Colors.white60, fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Pl. +35799123456',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.chat_rounded, color: Color(0xFF99FF99)),
                filled: true,
                fillColor: const Color(0xFF093753),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        );

      case 2:
      // 3. Lépés: Ár megadása
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ár / Díjszabás (€)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Pl. 1200',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF093753),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        );

      case 3:
      // 4. Lépés: Jellemzők (szoba, ágy, felszereltség / ingatlan paraméterek)
        return ListingDetailsForm(details: _details, isRent: _effectiveIsRent);

      case 4:
      // 5. Lépés: Leírás
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Részletes leírás', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Írja le részletesen az ajánlatot...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF093753),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        );

      case 5:
      // 6. Lépés: Helyszín a térképen
        return _buildLocationStep();

      case 6:
      // 7. Lépés: Fényképek
        return _buildPhotosStep();

      case 7:
      // 8. Lépés: Összegzés
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Összegzés és Ellenőrzés', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Kategória: ${_selectedCategory == 'Egyéb (Saját kategória megadása)' ? _customCategoryController.text : _selectedCategory}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('Cím: ${_titleController.text}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('Helyszín / Cím: ${_addressController.text}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('Telefon / WhatsApp: ${_normalizedPhone() ?? _phoneController.text}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            if (_hasListingType)
              Text('Típus: ${_effectiveIsRent ? 'Kiadó (${_priceUnit == 'month' ? 'havi' : 'éjszakai'} ár)' : 'Eladó'}', style: const TextStyle(color: Colors.white70)),
            if (_hasListingType) const SizedBox(height: 8),
            Text('Ár: ${_priceController.text} €', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            if (_hasListingType)
              Text(
                'Jellemzők: ${_effectiveIsRent ? '${_details.guests} vendég, ' : ''}${_details.bedrooms} hálószoba, ${_details.bathrooms} fürdő'
                '${_details.area != null ? ', ${_details.area} m²' : ''}, ${_details.amenities.length} extra',
                style: const TextStyle(color: Colors.white70),
              ),
            if (_hasListingType) const SizedBox(height: 8),
            Text('Leírás: ${_descriptionController.text}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(
              _pickedLocation == null
                  ? 'Térképes helyszín: nincs'
                  : 'Térképes helyszín: ${_pickedLocation!.latitude.toStringAsFixed(5)}, ${_pickedLocation!.longitude.toStringAsFixed(5)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text('Fotók: ${_photos.length} db', style: const TextStyle(color: Colors.white70)),
          ],
        );

      default:
        return Container();
    }
  }
}