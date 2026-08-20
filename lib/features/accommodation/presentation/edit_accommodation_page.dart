import 'package:flutter/material.dart';

class EditAccommodationPage extends StatefulWidget {
  final Map<String, String> accommodationData;

  const EditAccommodationPage({super.key, required this.accommodationData});

  @override
  State<EditAccommodationPage> createState() => _EditAccommodationPageState();
}

class _EditAccommodationPageState extends State<EditAccommodationPage> {
  final _formKey = GlobalKey<FormState>();

  static const Color bgColor = Color(0xFF0A1220);
  static const Color cardBg = Color(0xFF111E36);
  static const Color accentCyan = Color(0xFF00C0D4);

  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late TextEditingController _capacityController;
  late TextEditingController _descriptionController;

  String _cancellationPolicy = 'Flexible (Full refund up to 48 hours before arrival)';
  final List<String> _cancellationPolicies = [
    'Flexible (Full refund up to 48 hours before arrival)',
    'Moderate (Full refund up to 7 days before arrival)',
    'Strict (Full refund up to 14 days before arrival)',
    'Non-refundable (Discounted rate, no refund)',
  ];

  String _status = 'Active';
  final List<String> _statusOptions = ['Active', 'Paused (Inactive)'];

  // CATEGORIES FOR FILTERING / SEARCH
  final List<Map<String, dynamic>> _allAccommodationTypes = [
    {'title': 'Luxury Villa & Pool', 'icon': Icons.villa_outlined},
    {'title': 'Seafront Apartment', 'icon': Icons.apartment_outlined},
    {'title': 'Mountain Retreat', 'icon': Icons.terrain_outlined},
    {'title': 'Car & SUV Rental', 'icon': Icons.directions_car_outlined},
    {'title': 'Private Yacht & Cruise', 'icon': Icons.sailing_outlined},
    {'title': 'Restaurant & Bar', 'icon': Icons.restaurant_outlined},
  ];

  final Set<String> _selectedAccommodationTypes = {
    'Luxury Villa & Pool',
    'Seafront Apartment',
  };

  // AMENITIES
  bool _hasWifi = true;
  bool _hasParking = true;
  bool _hasPool = true;
  bool _hasAC = true;
  bool _isPetFriendly = false;

  @override
  void initState() {
    super.initState();
    final item = widget.accommodationData;
    _titleController = TextEditingController(text: item['title'] ?? '');
    _locationController = TextEditingController(text: item['location'] ?? '');

    final priceStr = item['price'] ?? '220';
    final cleanedPrice = priceStr.replaceAll(RegExp(r'[^\d]'), '');
    _priceController = TextEditingController(text: cleanedPrice.isEmpty ? '220' : cleanedPrice);

    _capacityController = TextEditingController(text: '6');
    _descriptionController = TextEditingController(
      text: item['description'] ?? 'Exclusive property in Cyprus with modern amenities, free private parking, and high-speed Wi-Fi.',
    );
    _status = item['status'] == 'Active' ? 'Active' : 'Paused (Inactive)';
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
          content: Text('Listing details, categories and pricing updated successfully! 🎉'),
          backgroundColor: accentCyan,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF142036),
        title: const Text('Delete Listing', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to permanently delete this listing? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Listing deleted.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
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
        backgroundColor: const Color(0xFF0E192D),
        elevation: 0,
        title: const Text(
          'Edit Listing',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _confirmDelete,
            tooltip: 'Delete listing',
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
              // LISTING STATUS
              const Text(
                'Listing Status',
                style: TextStyle(color: accentCyan, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _status,
                dropdownColor: cardBg,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.toggle_on, color: accentCyan),
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: accentCyan),
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

              // LISTING CATEGORIES
              const Text(
                'Category / Type for Search 🏷️',
                style: TextStyle(color: accentCyan, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select matching search categories for your listing:',
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
                        color: isSelected ? accentCyan : cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? accentCyan : Colors.white24,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type['icon'],
                            size: 16,
                            color: isSelected ? Colors.black : accentCyan,
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

              // PRICING & CAPACITY
              const Text(
                'Pricing & Capacity 💰',
                style: TextStyle(color: accentCyan, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Price / night (€)',
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _capacityController,
                      label: 'Guests Capacity',
                      icon: Icons.people_outline,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // CANCELLATION POLICY
              const Text(
                'Cancellation Policy 📋',
                style: TextStyle(color: accentCyan, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _cancellationPolicy,
                isExpanded: true,
                dropdownColor: cardBg,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.policy_outlined, color: accentCyan),
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: accentCyan),
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

              // LISTING DETAILS
              const Text(
                'Listing Details 🏠',
                style: TextStyle(color: accentCyan, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _titleController,
                label: 'Property Title',
                icon: Icons.home_outlined,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _locationController,
                label: 'Location / Region',
                icon: Icons.location_on_outlined,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              // AMENITIES & FACILITIES
              const Text(
                'Key Amenities & Highlights 🛠️',
                style: TextStyle(color: accentCyan, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    _buildCheckbox('Free High-Speed Wi-Fi', Icons.wifi, _hasWifi, (v) => setState(() => _hasWifi = v!)),
                    _buildCheckbox('Free Private Parking', Icons.local_parking, _hasParking, (v) => setState(() => _hasParking = v!)),
                    _buildCheckbox('Swimming Pool', Icons.pool, _hasPool, (v) => setState(() => _hasPool = v!)),
                    _buildCheckbox('Air Conditioning', Icons.ac_unit, _hasAC, (v) => setState(() => _hasAC = v!)),
                    _buildCheckbox('Pet Friendly', Icons.pets, _isPetFriendly, (v) => setState(() => _isPetFriendly = v!)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // DESCRIPTION
              const Text(
                'Description 📝',
                style: TextStyle(color: accentCyan, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: accentCyan),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
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
        prefixIcon: Icon(icon, color: accentCyan),
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentCyan),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildCheckbox(String title, IconData icon, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      activeColor: accentCyan,
      checkColor: Colors.black,
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      secondary: Icon(icon, color: accentCyan),
    );
  }
}