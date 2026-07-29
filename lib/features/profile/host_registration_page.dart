import 'package:flutter/material.dart';

enum UserRole { guest, provider, business }

class HostRegistrationPage extends StatefulWidget {
  const HostRegistrationPage({super.key});

  @override
  State<HostRegistrationPage> createState() => _HostRegistrationPageState();
}

class _HostRegistrationPageState extends State<HostRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  UserRole _selectedRole = UserRole.guest;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ntakController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _websiteController = TextEditingController();

  final FocusNode _websiteFocusNode = FocusNode();
  bool _hasShownWebsitePopup = false;

  @override
  void initState() {
    super.initState();

    // POPUP FIGYELŐ A WEBOLDAL MEZŐHÖZ (SZÁLLÁSADÓ ÉS ÜZLET FÜLÖN EGYARÁNT)
    _websiteFocusNode.addListener(() {
      if (_websiteFocusNode.hasFocus && !_hasShownWebsitePopup) {
        _hasShownWebsitePopup = true;
        _showWebsiteOfferDialog();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ntakController.dispose();
    _taxNumberController.dispose();
    _websiteController.dispose();
    _websiteFocusNode.dispose();
    super.dispose();
  }

  // WEBOLDAL KÉSZÍTÉSES POPUP DIALOG
  void _showWebsiteOfferDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E261C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF8BC541), width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(Icons.language, color: Color(0xFF8BC541)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nincs még saját weboldalad?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Amennyiben nincs még saját weboldalad, a HegyGO csapata elkészíti Neked 25.000 Ft.(tárhely+domain)+havi 5000 Ft.(support díj) áron!\n\nBővebb információ: info@hegygo.hu',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Rendben, köszönöm',
                style: TextStyle(
                  color: Color(0xFF8BC541),
                  fontWeight: FontWeight.bold,
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
    return Scaffold(
      backgroundColor: const Color(0xFF07130A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'HegyGO Regisztráció',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FIÓK TÍPUSA CÍM
                const Text(
                  'Fiók típusa',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),

                // FIÓK TÍPUSA VÁLASZTÓ TAB-OK
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      _buildRoleTab('Vendég', UserRole.guest),
                      _buildRoleTab('Szállásadó', UserRole.provider),
                      _buildRoleTab('Üzlet', UserRole.business),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // TELJES NÉV / CÉGNÉV
                _buildInputField(
                  controller: _nameController,
                  label: 'Teljes név / Cégnév',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),

                // E-MAIL CÍM
                _buildInputField(
                  controller: _emailController,
                  label: 'E-mail cím',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // MEZŐK SZÁLLÁSADÓKNAK (NTAK SZÁM)
                if (_selectedRole == UserRole.provider) ...[
                  _buildInputField(
                    controller: _ntakController,
                    label: 'NTAK Regisztrációs Szám (Kötelező)',
                    icon: Icons.verified_user_outlined,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '* Az NTAK számot az adminisztrátor ellenőrzi. Jóváhagyás után, megkapod az „ELLENŐRZÖTT PARTNER” címet!',
                    style: TextStyle(
                      color: Color(0xFFFFC107),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // MEZŐK ÜZLETEKNEK (ADÓSZÁM ÉS NTAK SZÁM)
                if (_selectedRole == UserRole.business) ...[
                  _buildInputField(
                    controller: _taxNumberController,
                    label: 'Adószám (Kötelező)',
                    icon: Icons.receipt_long_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _ntakController,
                    label: 'NTAK Regisztrációs Szám (Opcionális)',
                    icon: Icons.verified_user_outlined,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '* Az NTAK számot az adminisztrátor ellenőrzi. Jóváhagyás után, megkapod az „ELLENŐRZÖTT PARTNER” címet!',
                    style: TextStyle(
                      color: Color(0xFFFFC107),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // SAJÁT WEBOLDAL (CSAK SZÁLLÁSADÓ/ÜZLET ESETÉN, PONTOSAN UGYANAZZAL A POPUP FIGYELŐVEL)
                if (_selectedRole != UserRole.guest) ...[
                  _buildInputField(
                    controller: _websiteController,
                    focusNode: _websiteFocusNode,
                    label: 'Saját weboldal címe (Opcionális)',
                    icon: Icons.language,
                  ),
                  const SizedBox(height: 16),
                ],

                // JELSZÓ
                _buildInputField(
                  controller: _passwordController,
                  label: 'Jelszó',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 32),

                // REGISZTRÁCIÓ GOMB
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sikeres regisztráció!'),
                            backgroundColor: Color(0xFF8BC541),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Regisztráció',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // FIÓK TÍPUSA TAB WIDGET (FÜL VÁLTÁSKOR LEHETŐVÉ TESZI A POPUP ÚJABBI MEGJELENÉSÉT)
  Widget _buildRoleTab(String label, UserRole role) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = role;
            _hasShownWebsitePopup = false; // Váltáskor visszaállítjuk, hogy az új fülön is felugorhasson
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8BC541) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // BEVITELI MEZŐ BUILDER WIDGET
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    FocusNode? focusNode,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white70, size: 20),
        filled: true,
        fillColor: Colors.black26,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8BC541)),
        ),
      ),
    );
  }
}