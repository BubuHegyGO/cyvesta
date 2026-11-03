import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/widgets/cyvesta_scaffold.dart';
import '../../../../core/services/listing_duplicate_service.dart';
import '../../../../core/services/auth_state.dart';

class AddListingWizardPage extends StatefulWidget {
  const AddListingWizardPage({super.key});

  @override
  State<AddListingWizardPage> createState() => _AddListingWizardPageState();
}

class _AddListingWizardPageState extends State<AddListingWizardPage> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Adatok a hirdetéshez
  String _selectedCategory = 'Ingatlan / Eladó-Kiadó';
  final TextEditingController _customCategoryController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _addressController = TextEditingController(); // Új mező a pontos címhez (duplikáció szűréshez)
  final TextEditingController _priceController = TextEditingController();
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
    _descriptionController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Utolsó lépés - Duplikáció ellenőrzés és Mentés
      _submitListing();
    }
  }

  Future<void> _submitListing() async {
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

      await FirebaseFirestore.instance.collection('listings').add({
        'partnerId': AuthState.currentUserId,
        'category': category,
        'title': _titleController.text.trim(),
        'address': address,
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'description': _descriptionController.text.trim(),
        'imageUrls': _uploadedImageUrls,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending', // Moderálásra vár
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
        });
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
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
                    'Hirdetés feladása (${_currentStep + 1}/5)',
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
                      _currentStep == 4 ? 'Küldés' : 'Következő',
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
              value: _selectedCategory,
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
      // 4. Lépés: Leírás
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

      case 4:
      // 5. Lépés: Összegzés
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
            Text('Ár: ${_priceController.text} €', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('Leírás: ${_descriptionController.text}', style: const TextStyle(color: Colors.white70)),
          ],
        );

      default:
        return Container();
    }
  }
}