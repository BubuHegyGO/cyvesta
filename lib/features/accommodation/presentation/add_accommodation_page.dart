import 'package:flutter/material.dart';
import '../../../../core/services/data_service.dart';

class AddAccommodationPage extends StatefulWidget {
  const AddAccommodationPage({super.key});

  @override
  State<AddAccommodationPage> createState() => _AddAccommodationPageState();
}

class _AddAccommodationPageState extends State<AddAccommodationPage> {
  static const Color bgColor = Color(0xFF07130A);
  static const Color accent = Color(0xFF8BC541);

  final _formKey = GlobalKey<FormState>();
  final DataService _dataService = DataService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _selectedCategory = 'Lombház';
  final List<String> _categories = ['Lombház', 'Faház', 'Vendégház', 'Borkóstoló'];

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveAccommodation() {
    if (_formKey.currentState!.validate()) {
      final newItem = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': _titleController.text.trim(),
        'category': _selectedCategory,
        'location': _locationController.text.trim(),
        'price': '${_priceController.text.trim()} Ft / éj',
        'rating': '5.0',
        'image': 'assets/images/matra_background.png',
        'isFavorite': false,
        'latitude': 47.87,
        'longitude': 20.00,
      };

      _dataService.addAccommodation(newItem);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF0D2113),
          content: Text(
            'Új szálláshely sikeresen feltöltve és közzétéve!',
            style: TextStyle(color: accent, fontWeight: FontWeight.bold),
          ),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text('Új Szálláshely Feltöltése', style: TextStyle(color: Colors.white, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _titleController,
                  label: 'Szálláshely megnevezése',
                  hint: 'pl. Mátraterenyei Lombház',
                  icon: Icons.home_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Adja meg a nevet!' : null,
                ),
                const SizedBox(height: 16),

                // KATEGÓRIA
                const Text('Kategória', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      dropdownColor: const Color(0xFF0D2113),
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _locationController,
                  label: 'Település / Helyszín',
                  hint: 'pl. Mátrafüred',
                  icon: Icons.location_on_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Adja meg a helyszínt!' : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _priceController,
                  label: 'Ár (Ft / éjszaka)',
                  hint: 'pl. 35000',
                  icon: Icons.payments_rounded,
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Adja meg az árat!' : null,
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _saveAccommodation,
                    child: const Text('Szálláshely Közzététele', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
            prefixIcon: Icon(icon, color: accent, size: 20),
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.35),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: accent)),
          ),
        ),
      ],
    );
  }
}