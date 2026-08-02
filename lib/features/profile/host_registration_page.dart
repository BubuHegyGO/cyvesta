import 'package:flutter/material.dart';

class HostRegistrationPage extends StatefulWidget {
  const HostRegistrationPage({super.key});

  @override
  State<HostRegistrationPage> createState() => _HostRegistrationPageState();
}

class _HostRegistrationPageState extends State<HostRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Fő típus: 'guest' (Vendég) vagy 'partner' (Partner)
  String _mainRole = 'partner';

  // Partner al-kategória: 'accommodation' (Szállás), 'gastronomy' (Vendéglátás), 'other' (Egyéb szolgáltatás)
  String _partnerType = 'accommodation';

  // Controller-ek
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _ntakNumberController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _ntakNumberController.dispose();
    _taxNumberController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  // WEBOLDAL AJÁNLAT POPUP
  void _showWebsiteOfferDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E261C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF8BC541), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.language, color: Color(0xFF8BC541), size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Nincs még saját weboldalad?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Amennyiben nincs még saját weboldalad, a HegyGO csapata elkészíti Neked 25.000 Ft. (tárhely+domain)+havi 5000 Ft. (support díj) áron!\n\nBővebb információ: info@hegygo.hu',
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Rendben, köszönöm',
              style: TextStyle(
                color: Color(0xFF8BC541),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Regisztráció',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. FELSŐ FŐGOMBOK: VENDÉG ÉS PARTNER
              Row(
                children: [
                  Expanded(
                    child: _buildRoleButton('guest', 'Vendég', Icons.person_outline),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildRoleButton('partner', 'Partner', Icons.handshake_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. HA PARTNER: HÁROM ALKATEGÓRIA GOMB
              if (_mainRole == 'partner') ...[
                const Text(
                  'Partner kategória választása:',
                  style: TextStyle(
                    color: Color(0xFF8BC541),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildPartnerTypeButton('accommodation', 'Szállás', Icons.home_outlined),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPartnerTypeButton('gastronomy', 'Vendéglátás', Icons.restaurant_outlined),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPartnerTypeButton('other', 'Egyéb szolgáltatás', Icons.grid_view_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // 3. KITÖLTENDŐ ADATOK (ŰRLAP)
              const Text(
                'Személyes & Kapcsolattartási Adatok',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              _buildTextField(_nameController, 'Teljes Név *', Icons.person),
              const SizedBox(height: 12),
              _buildTextField(_emailController, 'E-mail cím *', Icons.email, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildTextField(_phoneController, 'Telefonszám *', Icons.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),

              // HA PARTNER (SZÁLLÁS / VENDÉGLÁTÁS / EGYÉB SZOLGÁLTATÁS)
              if (_mainRole == 'partner') ...[
                const SizedBox(height: 12),
                const Text(
                  'Szolgáltatói & Céges Adatok',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  _businessNameController,
                  _partnerType == 'accommodation'
                      ? 'Szálláshely / Cég neve *'
                      : _partnerType == 'gastronomy'
                          ? 'Vendéglátóhely / Cég neve *'
                          : 'Szolgáltatás / Cég neve *',
                  Icons.business,
                ),
                const SizedBox(height: 12),

                // NTAK SZÁM CSAK A SZÁLLÁSADÓNÁL
                if (_partnerType == 'accommodation') ...[
                  _buildTextField(
                    _ntakNumberController,
                    'NTAK regisztrációs szám *',
                    Icons.confirmation_number_outlined,
                  ),
                  const SizedBox(height: 12),
                ],

                // SAJÁT WEBOLDAL MEZŐ A POPUPPAL (AUTOMATIKUSAN FELUGRÓ)
                TextFormField(
                  controller: _websiteController,
                  style: const TextStyle(color: Colors.white),
                  onTap: () => _showWebsiteOfferDialog(context),
                  decoration: InputDecoration(
                    labelText: 'Saját weboldal címe (Opcionális)',
                    labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                    prefixIcon: const Icon(Icons.language, color: Color(0xFF8BC541), size: 20),
                    filled: true,
                    fillColor: Colors.black38,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF8BC541)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _buildTextField(
                  _taxNumberController,
                  'Adószám / Nyilvántartási szám *',
                  Icons.receipt_long,
                ),
                const SizedBox(height: 12),
                _buildTextField(_locationController, 'Helyszín / Cím *', Icons.location_on),
              ],

              const SizedBox(height: 32),

              // 4. REGISZTRÁCIÓ BEKÜLDÉSE GOMB
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8BC541),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final String roleName = _mainRole == 'guest'
                          ? 'Vendég'
                          : _partnerType == 'accommodation'
                              ? 'Partner (Szállás)'
                              : _partnerType == 'gastronomy'
                                  ? 'Partner (Vendéglátás)'
                                  : 'Partner (Egyéb szolgáltatás)';

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sikeres regisztráció mint: $roleName!'),
                          backgroundColor: const Color(0xFF8BC541),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Regisztráció Véglegesítése',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- VENDÉG ÉS PARTNER FŐGOMBOK BUILDER ---
  Widget _buildRoleButton(String role, String label, IconData icon) {
    final bool isSelected = _mainRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _mainRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8BC541) : Colors.black45,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF8BC541) : Colors.white24,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- PARTNER AL-KATEGÓRIA GOMBOK BUILDER ---
  Widget _buildPartnerTypeButton(String type, String label, IconData icon) {
    final bool isSelected = _partnerType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _partnerType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A1E) : Colors.black26,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF8BC541) : Colors.white12,
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF8BC541) : Colors.white54,
              size: 18,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? const Color(0xFF8BC541) : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- BEVITELI MEZŐ BUILDER VALIDÁCIÓVAL ---
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ez a mező kötelező!';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF8BC541), size: 20),
        filled: true,
        fillColor: Colors.black38,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8BC541)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}