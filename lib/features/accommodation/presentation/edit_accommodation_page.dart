import 'package:flutter/material.dart';

class EditAccommodationPage extends StatefulWidget {
  final Map<String, String> accommodationData;

  const EditAccommodationPage({super.key, required this.accommodationData});

  @override
  State<EditAccommodationPage> createState() => _EditAccommodationPageState();
}

class _EditAccommodationPageState extends State<EditAccommodationPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late TextEditingController _capacityController;
  late TextEditingController _descriptionController;

  String _cancellationPolicy = 'Rugalmas (Ingyenes lemondás 48 órával érkezés előtt)';
  final List<String> _cancellationPolicies = [
    'Rugalmas (Ingyenes lemondás 48 órával érkezés előtt)',
    'Mérsékelt (Ingyenes lemondás 7 nappal érkezés előtt)',
    'Szigorú (Ingyenes lemondás 14 nappal érkezés előtt)',
    'Nem visszatérítendő (Kedvezményes ár, nincs lemondás)',
  ];

  String _status = 'Aktív';
  final List<String> _statusOptions = ['Aktív', 'Szüneteltetve (Inaktív)'];

  // --- KATEGÓRIÁK A KERESŐHÖZ (KÜLÖN ROMANTIKUS 2 FŐ ÉS WELLNESS) ---
  final List<Map<String, dynamic>> _allAccommodationTypes = [
    {'title': 'Romantikus 2 fő részére', 'icon': Icons.favorite_outline},
    {'title': 'Wellness', 'icon': Icons.hot_tub_outlined},
    {'title': 'Erdei & Lombházak', 'icon': Icons.forest_outlined},
    {'title': 'Állatbarát', 'icon': Icons.pets_outlined},
    {'title': 'Családi & Gyerekbarát', 'icon': Icons.family_restroom_outlined},
    {'title': 'Panorámás Luxus', 'icon': Icons.king_bed_outlined},
  ];

  final Set<String> _selectedAccommodationTypes = {
    'Romantikus 2 fő részére',
    'Wellness',
  };

  // --- EGYÉB SZOLGÁLTATÁSOK ---
  bool _hasWifi = true;
  bool _hasParking = true;
  bool _hasJacuzzi = true;
  bool _hasSauna = false;
  bool _isPetFriendly = true;

  @override
  void initState() {
    super.initState();
    final item = widget.accommodationData;
    _titleController = TextEditingController(text: item['title'] ?? '');
    _locationController = TextEditingController(text: item['location'] ?? '');
    
    final priceStr = item['price'] ?? '10000';
    final cleanedPrice = priceStr.replaceAll(RegExp(r'[^\d]'), '');
    _priceController = TextEditingController(text: cleanedPrice.isEmpty ? '10000' : cleanedPrice);
    
    _capacityController = TextEditingController(text: '4');
    _descriptionController = TextEditingController(
      text: item['description'] ?? 'Gyönyörű erdei környezetben lévő, teljesen felszerelt szálláshely, ingyenes parkolással és wifivel.',
    );
    _status = item['status'] == 'Aktív' ? 'Aktív' : 'Szüneteltetve (Inaktív)';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Szállás adatai, kategóriái és árai sikeresen frissítve! 🎉'),
          backgroundColor: Color(0xFF8BC541),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E261C),
        title: const Text('Hirdetés Törlése', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Biztosan törölni szeretnéd ezt a szálláshirdetést? Ez a művelet nem vonható vissza.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mégse', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Szálláshirdetés törölve.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('Törlés', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D160E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A1E),
        elevation: 0,
        title: const Text(
          'Szállás Szerkesztése',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _confirmDelete,
            tooltip: 'Hirdetés törlése',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HIRDETÉS STÁTUSZA
              const Text(
                'Hirdetés Státusza',
                style: TextStyle(color: Color(0xFF8BC541), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _status,
                dropdownColor: const Color(0xFF1A261C),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.toggle_on, color: Color(0xFF8BC541)),
                  filled: true,
                  fillColor: const Color(0xFF1A261C),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                ),
                items: _statusOptions.map((opt) {
                  return DropdownMenuItem(value: opt, child: Text(opt));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
              const SizedBox(height: 24),

              // SZÁLLÁS TÍPUSAI
              const Text(
                'Szállás Típusa / Besorolása (Keresőhöz) 🏷️',
                style: TextStyle(color: Color(0xFF8BC541), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Válaszd ki azokat a kategóriákat, amelyekre a vendégek rákereshetnek:',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: _allAccommodationTypes.map((type) {
                  final String title = type['title'];
                  final bool isSelected = _selectedAccommodationTypes.contains(title);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedAccommodationTypes.remove(title);
                        } else {
                          _selectedAccommodationTypes.add(title);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF8BC541) : const Color(0xFF1A261C),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF8BC541) : Colors.white24,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type['icon'],
                            size: 16,
                            color: isSelected ? Colors.black : const Color(0xFF8BC541),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            title,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ÁRAZÁS & KAPACITÁS
              const Text(
                'Árazás & Kapacitás Módosítása 💰',
                style: TextStyle(color: Color(0xFF8BC541), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Ár / fő / éj (Ft)',
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Kötelező' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _capacityController,
                      label: 'Férőhely (fő)',
                      icon: Icons.people_outline,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Kötelező' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // LEMONDÁSI SZABÁLYZAT
              const Text(
                'Lemondási Szabályzat 📋',
                style: TextStyle(color: Color(0xFF8BC541), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _cancellationPolicy,
                isExpanded: true,
                dropdownColor: const Color(0xFF1A261C),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.policy_outlined, color: Color(0xFF8BC541)),
                  filled: true,
                  fillColor: const Color(0xFF1A261C),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                ),
                items: _cancellationPolicies.map((policy) {
                  return DropdownMenuItem(value: policy, child: Text(policy, overflow: TextOverflow.ellipsis));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _cancellationPolicy = val);
                },
              ),
              const SizedBox(height: 24),

              // SZÁLLÁS ADATAI
              const Text(
                'Szállás Adatai 🏠',
                style: TextStyle(color: Color(0xFF8BC541), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _titleController,
                label: 'Szállás megnevezése',
                icon: Icons.home_outlined,
                validator: (val) => val == null || val.isEmpty ? 'Kötelező' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _locationController,
                label: 'Helyszín / Cím',
                icon: Icons.location_on_outlined,
                validator: (val) => val == null || val.isEmpty ? 'Kötelező' : null,
              ),
              const SizedBox(height: 24),

              // SZOLGÁLTATÁSOK & KÉNYELEM
              const Text(
                'Egyéb Szolgáltatások 🛠️',
                style: TextStyle(color: Color(0xFF8BC541), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A261C),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    _buildCheckbox('Ingyenes Wi-Fi', Icons.wifi, _hasWifi, (v) => setState(() => _hasWifi = v!)),
                    _buildCheckbox('Díjmentes Parkolás', Icons.local_parking, _hasParking, (v) => setState(() => _hasParking = v!)),
                    _buildCheckbox('Jakuzzi / Dézsafürdő', Icons.hot_tub, _hasJacuzzi, (v) => setState(() => _hasJacuzzi = v!)),
                    _buildCheckbox('Szauna', Icons.spa, _hasSauna, (v) => setState(() => _hasSauna = v!)),
                    _buildCheckbox('Állatbarát', Icons.pets, _isPetFriendly, (v) => setState(() => _isPetFriendly = v!)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // LEÍRÁS MÓDOSÍTÁSA
              const Text(
                'Leírás Módosítása 📝',
                style: TextStyle(color: Color(0xFF8BC541), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1A261C),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF8BC541)),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // MENTÉS GOMB
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8BC541),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Módosítások Mentése',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF8BC541)),
        filled: true,
        fillColor: const Color(0xFF1A261C),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF8BC541)),
        ),
      ),
    );
  }

  Widget _buildCheckbox(String title, IconData icon, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF8BC541),
      checkColor: Colors.black,
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      secondary: Icon(icon, color: const Color(0xFF8BC541)),
    );
  }
}