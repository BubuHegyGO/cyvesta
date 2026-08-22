import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthState {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  static final ValueNotifier<String> userName = ValueNotifier<String>('');
  static final ValueNotifier<String> userEmail = ValueNotifier<String>('');
  static final ValueNotifier<bool> isPartner = ValueNotifier<bool>(false);

  static void init() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        isLoggedIn.value = true;
        userEmail.value = user.email ?? '';
        userName.value = user.displayName ?? (user.email?.split('@').first ?? 'Felhasználó');
      } else {
        isLoggedIn.value = false;
        userName.value = '';
        userEmail.value = '';
      }
    });
  }

  // Valós E-mail & Jelszavas Regisztráció Firebase-ben
  static Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required bool asPartner,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      isLoggedIn.value = true;
      userEmail.value = email;
      userName.value = name;
      isPartner.value = asPartner;
      return true;
    } catch (e) {
      debugPrint('Firebase regisztrációs hiba: $e');
      return false;
    }
  }

  // Valós E-mail & Jelszavas Bejelentkezés Firebase-ben
  static Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      isLoggedIn.value = true;
      userEmail.value = email;
      userName.value = credential.user?.displayName ?? email.split('@').first;
      return true;
    } catch (e) {
      debugPrint('Firebase bejelentkezési hiba: $e');
      return false;
    }
  }

  // Kijelentkezés
  static Future<void> logout() async {
    await _auth.signOut();
    isLoggedIn.value = false;
    userName.value = '';
    userEmail.value = '';
    isPartner.value = false;
  }

  // Tartalék / Social login
  static void loginWithProvider(String provider) {
    isLoggedIn.value = true;
    userName.value = '$provider Felhasználó';
    userEmail.value = 'user@${provider.toLowerCase()}.com';
  }
}