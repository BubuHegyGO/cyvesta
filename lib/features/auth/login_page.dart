import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  static const Color bgColor = Color(0xFF07130A);
  static const Color accent = Color(0xFF8BC541);

  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Controller-ek
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isRegPasswordObscured = true;
  String _userRole = 'guest'; // 'guest' vagy 'host'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_loginFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF0D2113),
          content: Text('Sikeres bejelentkezés! Üdvözöl a HegyGO! 🏔️'),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _handleRegister() {
    if (_registerFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF0D2113),
          content: Text(
            _userRole == 'host'
                ? 'Sikeres regisztráció! Szállásadói fiókod elkészült.'
                : 'Sikeres regisztráció! Jó böngészést kívánunk!',
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showForgotPasswordDialog() {
    final emailResetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D2113),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Jelszó visszaállítása',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add meg az e-mail címedet, és küldünk egy hivatkozást a jelszavad megváltoztatásához.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailResetController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'E-mail cím',
                labelStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.email_outlined, color: accent),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mégse', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color(0xFF07130A),
                  content: Text('A jelszóvisszaállító linket elküldtük az e-mail címedre!'),
                ),
              );
            },
            child: const Text('Küldés', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FEJLÉC ÉS LOGÓ HARMÓNIA
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: accent.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.terrain_rounded, color: accent, size: 42),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'HegyGO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'A Mátra és Bükk élményportálja',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // TAB BAR (BEJELENTKEZÉS / REGISZTRÁCIÓ)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: accent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: accent,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  tabs: const [
                    Tab(text: 'Bejelentkezés'),
                    Tab(text: 'Regisztráció'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // TAB NÉZETEK TARTALMA
              SizedBox(
                height: 420,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLoginForm(),
                    _buildRegisterForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. BEJELENTKEZÉSI ŰRLAP
  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _loginEmailController,
            label: 'E-mail cím',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (val) => val == null || !val.contains('@') ? 'Érvényes e-mail címet adj meg' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _loginPasswordController,
            label: 'Jelszó',
            icon: Icons.lock_outline_rounded,
            isObscure: _isPasswordObscured,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.white54,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordObscured = !_isPasswordObscured;
                });
              },
            ),
            validator: (val) => val == null || val.length < 6 ? 'A jelszó legalább 6 karakter legyen' : null,
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPasswordDialog,
              child: const Text(
                'Elfelejtetted a jelszavad?',
                style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _handleLogin,
              child: const Text(
                'Bejelentkezés',
                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // 2. REGISZTRÁCIÓS ŰRLAP
  Widget _buildRegisterForm() {
    return Form(
      key: _registerFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SZEREPKÖR VÁLASZTÓ
            Row(
              children: [
                Expanded(
                  child: _buildRoleCard(
                    roleKey: 'guest',
                    label: 'Vendég vagyok',
                    icon: Icons.person_outline_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildRoleCard(
                    roleKey: 'host',
                    label: 'Szállásadó vagyok',
                    icon: Icons.other_houses_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: _regNameController,
              label: 'Teljes Neved',
              icon: Icons.person_outline_rounded,
              validator: (val) => val == null || val.isEmpty ? 'Kérjük, add meg a nevedet' : null,
            ),
            const SizedBox(height: 12),

            _buildTextField(
              controller: _regEmailController,
              label: 'E-mail cím',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (val) => val == null || !val.contains('@') ? 'Érvényes e-mail címet adj meg' : null,
            ),
            const SizedBox(height: 12),

            _buildTextField(
              controller: _regPasswordController,
              label: 'Jelszó',
              icon: Icons.lock_outline_rounded,
              isObscure: _isRegPasswordObscured,
              suffixIcon: IconButton(
                icon: Icon(
                  _isRegPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.white54,
                ),
                onPressed: () {
                  setState(() {
                    _isRegPasswordObscured = !_isRegPasswordObscured;
                  });
                },
              ),
              validator: (val) => val == null || val.length < 6 ? 'A jelszó legalább 6 karakter legyen' : null,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _handleRegister,
                child: const Text(
                  'Fiók Létrehozása',
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String roleKey,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _userRole == roleKey;

    return GestureDetector(
      onTap: () {
        setState(() {
          _userRole = roleKey;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D2113) : Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accent : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? accent : Colors.white54, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isObscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
        prefixIcon: Icon(icon, color: accent, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}