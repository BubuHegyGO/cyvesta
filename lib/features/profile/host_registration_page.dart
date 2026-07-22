import 'package:flutter/material.dart';

class HostRegistrationPage extends StatefulWidget {
  const HostRegistrationPage({super.key});

  @override
  State<HostRegistrationPage> createState() => _HostRegistrationPageState();
}

class _HostRegistrationPageState extends State<HostRegistrationPage> {
  static const Color bgColor = Color(0xFF07130A);
  static const Color accent = Color(0xFF8BC541);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ntakController = TextEditingController();
  final TextEditingController _taxNumberController = TextEditingController();
  final TextEditingController _propertyNameController = TextEditingController();

  @override
  void dispose() {
    _ntakController.dispose();
    _taxNumberController.dispose();
    _propertyNameController.dispose();
    super.dispose();
  }

  void _submitHostRegistration() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF0D2113),
          content: Text(
            'Sikeres szállásadói regisztráció! NTAK szám elfogadva.',
            style: TextStyle(color: accent, fontWeight: FontWeight.bold),
          ),
        ),
      );
      Navigator.pop(context, true); // Visszatérés 'true' státusszal
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text('Szállásadói Regisztráció', style: TextStyle(color: Colors.white, fontSize: 18)),
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
                const Text(
                  'Legyél te is HegyGO Szállásadó!',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Adja meg a hivatalos szálláshely adatait a regisztrációhoz.',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),

                const SizedBox(height: 24),

                // NTAK SZÁM MEZŐ
                _buildTextField(
                  controller: _ntakController,
                  label: 'NTAK Regisztrációs Szám',
                  hint: 'pl. MA22001234',
                  icon: Icons.verified_user_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'A megadása kötelező!';
                    }
                    if (value.trim().length < 6) {
                      return 'Kérjük adjon meg érvényes NTAK számot!';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ADÓSZÁM MEZŐ
                _buildTextField(
                  controller: _taxNumberController,
                  label: 'Adószám vagy Adóazonosító',
                  hint: '12345678-1-12',
                  icon: Icons.badge_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Az adószám megadása kötelező!';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ELSŐDLEGES SZÁLLÁSHELY NEVE
                _buildTextField(
                  controller: _propertyNameController,
                  label: 'Elsődleges Szálláshely Neve',
                  hint: 'pl. Mátrai Erdei Kisház',
                  icon: Icons.cabin_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Adja meg a szálláshely nevét!';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // REGISZTRÁCIÓ GOMB
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _submitHostRegistration,
                    child: const Text(
                      'Regisztráció és Átváltás Szállásadóvá',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
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
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
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