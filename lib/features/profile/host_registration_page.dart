import 'package:flutter/material.dart';

class HostRegistrationPage extends StatefulWidget {
  const HostRegistrationPage({Key? key}) : super(key: key);

  @override
  State<HostRegistrationPage> createState() => _HostRegistrationPageState();
}

class _HostRegistrationPageState extends State<HostRegistrationPage> {
  String _selectedCategory = 'Apartman, Villa';
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyRegController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isCompanyTypeHE = true;
  bool _isChatEnabled = true;
  bool _acceptTerms = false;

  final List<String> _categories = [
    'Apartman, Villa',
    'Szálloda, Hotel',
    'Élmény & Túra',
    'Gasztronómia',
    'Autóbérlés & Transzfer',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _companyNameController.dispose();
    _companyRegController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _verifyCompany() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cégadatok ellenőrzése folyamatban...'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B192C), // Sötét háttér igazodva a CYVESTA-hoz
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Partner Regisztráció',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Kategória:', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.withOpacity(0.5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.orange),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField('Teljes Név *', Icons.person, _nameController),
              const SizedBox(height: 16),
              _buildTextField('E-mail cím *', Icons.email, _emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField('Telefonszám *', Icons.phone, _phoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField('Jelszó *', Icons.lock, _passwordController, obscureText: true),
              const SizedBox(height: 24),

              const Text('Vállalkozási Adatok', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              _buildTextField('Vállalkozás Neve *', Icons.business, _companyNameController),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isCompanyTypeHE = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isCompanyTypeHE ? Colors.orange : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Céges (HE szám)',
                            style: TextStyle(
                              color: _isCompanyTypeHE ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isCompanyTypeHE = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isCompanyTypeHE ? Colors.orange : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Egyéni / Adószám (VAT)',
                            style: TextStyle(
                              color: !_isCompanyTypeHE ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _isCompanyTypeHE ? 'Cégjegyzékszám (pl. HE 475909)' : 'Adószám / VAT',
                      Icons.badge,
                      _companyRegController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _verifyCompany,
                    child: const Text('Ellenőrzés', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildTextField('Saját Weboldal Linkje (opcionális)', Icons.language, _websiteController),
              const SizedBox(height: 16),
              _buildTextField('Cím / Helyszín Cipruson *', Icons.location_on, _addressController),
              const SizedBox(height: 20),

              SwitchListTile(
                title: const Text('Közvetlen chat lehetőség biztosítása', style: TextStyle(color: Colors.white)),
                value: _isChatEnabled,
                activeColor: Colors.orange,
                onChanged: (bool value) {
                  setState(() {
                    _isChatEnabled = value;
                  });
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'ℹ Hotelek és Apartmanok számára a chat és a Push értesítések automatikusan aktívak.',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    activeColor: Colors.orange,
                    onChanged: (val) => setState(() => _acceptTerms = val ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      'Elfogadom az ÁSZF-et és a GDPR-t. *',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // Partner regisztráció mentése
                },
                child: const Text(
                  'Regisztráció',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.orange),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}