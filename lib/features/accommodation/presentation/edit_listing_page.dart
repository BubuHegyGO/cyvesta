import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/auth_state.dart';
import '../../../core/services/ical_service.dart';
import '../../../core/services/listing_duplicate_service.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/cyvesta_scaffold.dart';
import 'steps/listing_details_form.dart';

/// Meglévő hirdetés szerkesztése. A kategória, a típus (kiadó/eladó) és a térképes pont nem módosítható.
/// Partner szerkesztése után a hirdetés újra ellenőrzésre kerül (pár másodperc), az admin módosítása azonnali.
class EditListingPage extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> doc;

  const EditListingPage({super.key, required this.doc});

  @override
  State<EditListingPage> createState() => _EditListingPageState();
}

class _EditListingPageState extends State<EditListingPage> {
  static const Color _field = Color(0xFF093753);
  static const Color _mint = Color(0xFF99FF99);
  static const Color _gold = Color(0xFFFF9F1C);
  static const int _maxPhotos = 10;

  late final Map<String, dynamic> _d;
  final _title = TextEditingController();
  final _address = TextEditingController();
  final _price = TextEditingController();
  final _phone = TextEditingController();
  final _description = TextEditingController();
  final ListingDetails _details = ListingDetails();
  final ImagePicker _picker = ImagePicker();

  late List<String> _existingUrls;
  final List<String> _removedUrls = [];
  final List<XFile> _newPhotos = [];
  final List<Reference> _uploadedRefs = [];

  String _priceUnit = 'night';
  bool _saving = false;
  String _status = '';

  String? get _type => _d['listingType']?.toString(); // rent | sale | null
  bool get _hasType => _type == 'rent' || _type == 'sale';
  bool get _isRent => _type == 'rent';

  @override
  void initState() {
    super.initState();
    _d = widget.doc.data() ?? {};
    _title.text = (_d['title'] ?? '').toString();
    _address.text = (_d['address'] ?? '').toString();
    final p = _d['price'];
    _price.text = p is num ? (p == p.roundToDouble() ? p.toInt().toString() : p.toString()) : '';
    _phone.text = (_d['contactPhone'] ?? '').toString();
    _description.text = (_d['description'] ?? '').toString();
    _priceUnit = _d['priceUnit'] == 'month' ? 'month' : 'night';
    _existingUrls = _d['imageUrls'] is List ? List<String>.from((_d['imageUrls'] as List).map((e) => e.toString())) : <String>[];
    if (_d['details'] is Map) _details.loadFrom(Map<String, dynamic>.from(_d['details'] as Map));
    _details.icalCtrl.text = (_d['icalUrl'] ?? '').toString();
  }

  @override
  void dispose() {
    _title.dispose();
    _address.dispose();
    _price.dispose();
    _phone.dispose();
    _description.dispose();
    _details.dispose();
    super.dispose();
  }

  int get _photoCount => _existingUrls.length + _newPhotos.length;

  String? _normalizedPhone() {
    var p = _phone.text.trim().replaceAll(RegExp(r'[\s\-().]'), '');
    if (p.startsWith('00')) p = '+${p.substring(2)}';
    return RegExp(r'^\+[0-9]{8,15}$').hasMatch(p) ? p : null;
  }

  Future<void> _pickPhotos() async {
    final remaining = _maxPhotos - _photoCount;
    if (remaining <= 0) {
      _snack('Maximum 10 db fotó lehet.', Colors.orange);
      return;
    }
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 80, maxWidth: 1600, maxHeight: 1600);
      if (picked.isEmpty || !mounted) return;
      setState(() => _newPhotos.addAll(picked.take(remaining)));
    } catch (e) {
      _snack('A fotóválasztás nem sikerült: $e', Colors.redAccent);
    }
  }

  void _snack(String text, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color));
  }

  String? _validate() {
    if (_title.text.trim().isEmpty) return 'Add meg a hirdetés címét.';
    if (_address.text.trim().isEmpty) return 'Add meg a pontos címet.';
    final price = double.tryParse(_price.text.trim().replaceAll(',', '.'));
    if (price == null || price < 0) return 'Adj meg érvényes árat.';
    if (_normalizedPhone() == null) return 'Add meg a telefonszámot nemzetközi formátumban (pl. +35799123456).';
    if (_hasType) {
      final err = _details.validate(isRent: _isRent);
      if (err != null) return err;
    }
    if (_photoCount < 1) return 'Legalább 1 fényképnek maradnia kell.';
    return null;
  }

  Future<List<String>> _uploadNew(String uid) async {
    final storage = FirebaseStorage.instance;
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final urls = <String>[];
    for (var i = 0; i < _newPhotos.length; i++) {
      if (mounted) setState(() => _status = 'Fotók feltöltése (${i + 1}/${_newPhotos.length})...');
      final path = _newPhotos[i].path;
      final dot = path.lastIndexOf('.');
      var ext = dot >= 0 ? path.substring(dot + 1).toLowerCase() : 'jpg';
      if (!const ['jpg', 'jpeg', 'png', 'webp', 'heic'].contains(ext)) ext = 'jpg';
      final contentType = (ext == 'jpg' || ext == 'jpeg') ? 'image/jpeg' : 'image/$ext';
      final ref = storage.ref('listings/$uid/${stamp}_e$i.$ext');
      await ref.putFile(File(path), SettableMetadata(contentType: contentType));
      _uploadedRefs.add(ref);
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  Future<void> _save() async {
    final err = _validate();
    if (err != null) {
      _snack('$err ⚠️', Colors.redAccent);
      return;
    }
    final uid = AuthState.currentUserId;
    if (uid == null) {
      _snack('Be kell jelentkezned.', Colors.redAccent);
      return;
    }

    setState(() {
      _saving = true;
      _status = '';
    });

    try {
      await AuthState.refreshRoles();
      final isAdmin = AuthState.isAdmin.value;

      final uploaded = await _uploadNew(uid);
      final address = _address.text.trim();
      final icalUrl = _isRent ? ICalService.normalizeUrl(_details.icalCtrl.text) : null;

      final update = <String, dynamic>{
        'title': _title.text.trim(),
        'address': address,
        'addressNormalized': ListingDuplicateService.normalizeAddress(address),
        'price': double.parse(_price.text.trim().replaceAll(',', '.')),
        'contactPhone': _normalizedPhone(),
        'description': _description.text.trim(),
        'imageUrls': [..._existingUrls, ...uploaded],
        if (_hasType) 'details': _details.toMap(isRent: _isRent),
        if (_isRent) 'priceUnit': _priceUnit,
        if (_isRent) 'icalUrl': icalUrl ?? FieldValue.delete(),
        // Partner módosítása után újra ellenőrzés kell; az admin módosítása azonnal él.
        if (!isAdmin) 'status': 'pending',
      };

      await widget.doc.reference.update(update);

      // A törölt fotókat a tárhelyről is töröljük (a hirdetés már nem hivatkozik rájuk).
      for (final u in _removedUrls) {
        try {
          await FirebaseStorage.instance.refFromURL(u).delete();
        } catch (_) {}
      }

      if (mounted) {
        _snack(isAdmin ? 'A hirdetés frissítve. ✅' : 'Módosítva. Az automatikus ellenőrzés után újra elérhető lesz. ✅', Colors.green);
        Navigator.pop(context);
      }
    } catch (e) {
      for (final r in _uploadedRefs) {
        try {
          await r.delete();
        } catch (_) {}
      }
      _uploadedRefs.clear();
      _snack('A mentés nem sikerült: $e', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      );

  Widget _input(TextEditingController c, String hint, {int maxLines = 1, TextInputType? type}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: _field,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _photos() {
    final total = _photoCount;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: total + (total < _maxPhotos ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == total) {
          return GestureDetector(
            onTap: _pickPhotos,
            child: Container(
              decoration: BoxDecoration(color: _field, borderRadius: BorderRadius.circular(12), border: Border.all(color: _mint, width: 1.5)),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, color: _gold, size: 30),
                  SizedBox(height: 4),
                  Text('Hozzáadás', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          );
        }
        final isExisting = index < _existingUrls.length;
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: isExisting
                  ? AppImage(_existingUrls[index], fit: BoxFit.cover)
                  : Image.file(File(_newPhotos[index - _existingUrls.length].path), fit: BoxFit.cover),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => setState(() {
                  if (isExisting) {
                    _removedUrls.add(_existingUrls.removeAt(index));
                  } else {
                    _newPhotos.removeAt(index - _existingUrls.length);
                  }
                }),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return CyvestaScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF072A40),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: _mint, size: 18),
                      onPressed: _saving ? null : () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Hirdetés szerkesztése', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_d['category'] ?? ''}${_hasType ? ' · ${_isRent ? 'Kiadó' : 'Eladó'}' : ''}',
                      style: const TextStyle(color: _mint, fontSize: 12),
                    ),
                    _label('Cím'),
                    _input(_title, 'Hirdetés címe'),
                    _label('Pontos cím'),
                    _input(_address, 'Pl. Poseidonos Avenue 12, Paphos'),
                    _label(_isRent ? 'Ár (€)' : 'Ár (€)'),
                    _input(_price, 'Pl. 120', type: const TextInputType.numberWithOptions(decimal: true)),
                    if (_isRent) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children: [
                          ChoiceChip(label: const Text('€ / éj'), selected: _priceUnit == 'night', onSelected: (_) => setState(() => _priceUnit = 'night')),
                          ChoiceChip(label: const Text('€ / hó'), selected: _priceUnit == 'month', onSelected: (_) => setState(() => _priceUnit = 'month')),
                        ],
                      ),
                    ],
                    _label('Telefonszám / WhatsApp'),
                    _input(_phone, 'Pl. +35799123456', type: TextInputType.phone),
                    _label('Leírás'),
                    _input(_description, 'Írja le részletesen az ajánlatot...', maxLines: 5),
                    if (_hasType) ...[
                      const SizedBox(height: 8),
                      ListingDetailsForm(details: _details, isRent: _isRent),
                    ],
                    _label('Fényképek ($_photoCount / $_maxPhotos)'),
                    _photos(),
                    const SizedBox(height: 12),
                    const Text(
                      'A kategória, a típus és a térképes helyszín nem módosítható. Ha ezeket át kell írni, add fel újra a hirdetést.',
                      style: TextStyle(color: Colors.white54, fontSize: 11.5),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            if (_saving && _status.isNotEmpty) Text(_status, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _gold, foregroundColor: Colors.white),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Mentés', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
