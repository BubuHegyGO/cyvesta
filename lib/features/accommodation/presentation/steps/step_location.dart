import 'package:flutter/material.dart';

class StepLocation extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController zipController;
  final TextEditingController cityController;
  final TextEditingController addressController;

  const StepLocation({
    super.key,
    required this.formKey,
    required this.zipController,
    required this.cityController,
    required this.addressController,
  });

  @override
  State<StepLocation> createState() => _StepLocationState();
}

class _StepLocationState extends State<StepLocation> {
  static const Color accent = Color(0xFF8BC541);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hol található a szálláshelyed?',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Add meg a pontos címet, hogy a vendégek könnyen odataláljanak!',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Irányítószám és Település egy sorban
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Irányítószám *',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: widget.zipController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration('pl. 3200'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Kötelező!';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Település *',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: widget.cityController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration('pl. Gyöngyös / Mátrafüred'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Kérjük, add meg a települést!';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Utca, házszám
            const Text(
              'Utca, házszám *',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.addressController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration('pl. Egerverő út 12.'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Kérjük, add meg az utcát és házszámot!';
                }
                return null;
              },
            ),

            const SizedBox(height: 28),

            // Térképes Pozíció Előnézet (Dummy Box a Google Maps integráció előkészítéséhez)
            const Text(
              'Helymeghatározás a térképen',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.4)),
                image: const DecorationImage(
                  image: AssetImage('assets/images/matra_background.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.location_on, color: accent, size: 45),
                  Positioned(
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.touch_app, color: accent, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'Kattints a pin pontosításához',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
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

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.35),
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}