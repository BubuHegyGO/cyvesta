import 'package:flutter/material.dart';
import '../../../../core/widgets/cyvesta_scaffold.dart';

class AddListingWizardPage extends StatefulWidget {
  const AddListingWizardPage({super.key});

  @override
  State<AddListingWizardPage> createState() => _AddListingWizardPageState();
}

class _AddListingWizardPageState extends State<AddListingWizardPage> {
  int _currentStep = 0;
  
  // Adatok a hirdetéshez
  String _selectedCategory = 'Ingatlan / Eladó-Kiadó';
  final TextEditingController _customCategoryController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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
      // Utolsó lépés - Mentés / Véglegesítés
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hirdetés sikeresen elküldve moderálásra!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
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
                    onPressed: _previousStep,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF99FF99)),
                    ),
                    child: const Text('Vissza', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9F1C),
                    ),
                    child: Text(
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
        // 1. Lépés: Kategória kiválasztása vagy saját megadása
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
        // 2. Lépés: Cím megadása
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