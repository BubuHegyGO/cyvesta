import 'package:flutter/material.dart';

import 'steps/step_amenities.dart';
import 'steps/step_location.dart';
import 'steps/step_photos.dart';
import 'steps/step_pricing.dart';

class AddAccommodationPage extends StatefulWidget {
  const AddAccommodationPage({super.key});

  @override
  State<AddAccommodationPage> createState() => _AddAccommodationPageState();
}

class _AddAccommodationPageState extends State<AddAccommodationPage> {
  static const Color bgColor = Color(0xFF07130A);
  static const Color accent = Color(0xFF8BC541);

  int _currentStep = 0;

  final _formKey0 = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  final _zipController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ntakController = TextEditingController();
  final _websiteController = TextEditingController(); // Saját weboldal controller

  String _selectedRegion = 'Mátra';
  int _maxGuests = 2;
  int _bedrooms = 1;
  int _beds = 1;
  bool _isHighlight = false;

  final List<String> _selectedAmenities = [];
  final List<String> _uploadedPhotos = [];

  @override
  void dispose() {
    _zipController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    _ntakController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      _submitForm();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _submitForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: accent, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.hourglass_top_rounded, color: accent, size: 28),
            SizedBox(width: 10),
            Text('Sikeres rögzítés!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'A szálláshirdetésed sikeresen rögzítésre került.\n\nStátusz: Adminisztrátori jóváhagyásra vár (Ellenőrzés alatt). Az ellenőrzést követően azonnal megjelenik a HegyGO kínálatában.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Rendben', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text('Új szállás feladása 🏡', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: List.generate(4, (index) {
                  final isActive = index <= _currentStep;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive ? accent : Colors.white12,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                )
                              ]
                            : [],
                      ),
                    ),
                  );
                }),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentStep + 1}. Lépés: ${_getStepTitle(_currentStep)}',
                    style: const TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    '${_currentStep + 1} / 4',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildStepContent(_currentStep),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                border: const Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _previousStep,
                        child: const Text('Vissza', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _nextStep,
                      child: Text(
                        _currentStep == 3 ? 'Hirdetés Beküldése' : 'Tovább',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
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

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Alapadatok & Helyszín';
      case 1:
        return 'Felszereltség';
      case 2:
        return 'Képek feltöltése';
      case 3:
        return 'Árazás & Kapcsolat';
      default:
        return '';
    }
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return StepLocation(
          formKey: _formKey0,
          zipController: _zipController,
          cityController: _cityController,
          addressController: _addressController,
          titleController: _titleController,
          descriptionController: _descriptionController,
          ntakController: _ntakController,
          websiteController: _websiteController, // Ātadva!
          selectedRegion: _selectedRegion,
          maxGuests: _maxGuests,
          bedrooms: _bedrooms,
          beds: _beds,
          onRegionChanged: (val) {
            if (val != null) setState(() => _selectedRegion = val);
          },
          onGuestsChanged: (val) => setState(() => _maxGuests = val),
          onBedroomsChanged: (val) => setState(() => _bedrooms = val),
          onBedsChanged: (val) => setState(() => _beds = val),
        );
      case 1:
        return StepAmenities(
          formKey: _formKey1,
          selectedAmenities: _selectedAmenities,
          onAmenitiesChanged: (amenities) {
            setState(() {
              _selectedAmenities.clear();
              _selectedAmenities.addAll(amenities);
            });
          },
        );
      case 2:
        return StepPhotos(
          formKey: _formKey2,
          uploadedPhotos: _uploadedPhotos,
          onPhotosChanged: (photos) {
            setState(() {
              _uploadedPhotos.clear();
              _uploadedPhotos.addAll(photos);
            });
          },
        );
      case 3:
        return StepPricing(
          formKey: _formKey3,
          priceController: _priceController,
          phoneController: _phoneController,
          isHighlight: _isHighlight,
          onHighlightChanged: (val) => setState(() => _isHighlight = val),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}