import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/localization/app_language.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _acceptedTerms = false;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _registerPartner() async {
    if (_nameController.text.trim().isEmpty ||
        _businessNameController.text.trim().isEmpty ||
        _taxNumberController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Minden mező kitöltése kötelező! ⚠️';
      });
      return;
    }

    if (!_acceptedTerms) {
      setState(() {
        _errorMessage = 'Az ÁSZF és a GDPR elfogadása kötelező a regisztrációhoz! ⚠️';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }

      await FirebaseFirestore.instance.collection('partners').doc(user?.uid).set({
        'name': _nameController.text.trim(),
        'businessName': _businessNameController.text.trim(),
        'taxNumber': _taxNumberController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'emailVerified': false,
        'acceptedTerms': true,
        'createdAt': Timestamp.now(),
        'role': 'partner',
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sikeres regisztráció! Kérjük, ellenőrizd az e-mail fiókodat a megerősítéshez.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Hiba történt a regisztráció során.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Hiba történt: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sikeres kijelentkezés.')),
        );
        setState(() {});
      }
    } catch (e) {
      debugPrint('SignOut error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser;
    try {
      currentUser = FirebaseAuth.instance.currentUser;
    } catch (e) {
      currentUser = null;
    }

    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLanguage.tr('profile_app_bar_title')),
            backgroundColor: const Color(0xFF061822),
            actions: [
              if (currentUser != null)
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: AppLanguage.tr('auth_logout_btn'),
                  onPressed: _signOut,
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: currentUser != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Icon(Icons.check_circle, size: 80, color: Colors.teal),
                      const SizedBox(height: 16),
                      Text(
                        '${AppLanguage.tr('auth_logged_in_as')}\n${currentUser.email}',
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout),
                        label: Text(AppLanguage.tr('auth_logout_btn')),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppLanguage.tr('profile_section_title'),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: AppLanguage.tr('auth_name_hint'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _businessNameController,
                        decoration: InputDecoration(
                          labelText: AppLanguage.tr('auth_business_name_hint'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _taxNumberController,
                        decoration: InputDecoration(
                          labelText: AppLanguage.tr('auth_tax_hint'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: AppLanguage.tr('auth_address_hint'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: AppLanguage.tr('auth_phone_hint'),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: AppLanguage.tr('auth_email_hint'),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: AppLanguage.tr('auth_password_hint'),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Checkbox(
                            value: _acceptedTerms,
                            activeColor: Colors.amber,
                            checkColor: const Color(0xFF0F172A),
                            onChanged: (val) {
                              setState(() {
                                _acceptedTerms = val ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final url = Uri.parse('https://docs.google.com/document/d/1qE_7YtmwU7baCj8XB7GAzaPhxzS2yGs8yep1synu7zA/edit?usp=drive_web');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Text(
                                AppLanguage.tr('terms_acceptance'),
                                style: const TextStyle(
                                  color: Color(0xFF99FF99),
                                  fontSize: 12,
                                  height: 1.3,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _registerPartner,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(
                                AppLanguage.tr('profile_register_btn_text'),
                                style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}