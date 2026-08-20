import 'package:flutter/material.dart';

class AuthState {
  static final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  static final ValueNotifier<String> userEmail = ValueNotifier<String>('');
  static final ValueNotifier<String> userName = ValueNotifier<String>('');
  static final ValueNotifier<bool> isPartner = ValueNotifier<bool>(false);

  /// Közvetlen bejelentkezés és regisztráció (névvel, e-maillel és szerepkörrel)
  static void login({
    required String name,
    required String email,
    bool asPartner = false,
  }) {
    userName.value = name.isNotEmpty ? name : (email.isNotEmpty ? email.split('@').first : 'CYVESTA Felhasználó');
    userEmail.value = email;
    isPartner.value = asPartner;
    isLoggedIn.value = true;
  }

  /// E-mail & jelszavas belépés
  static void loginWithEmail(String email, String name, {bool asPartner = false}) {
    userEmail.value = email;
    userName.value = name.isNotEmpty ? name : email.split('@').first;
    isPartner.value = asPartner;
    isLoggedIn.value = true;
  }

  /// Közösségi belépés (Google, Apple, Facebook)
  static void loginWithProvider(String provider) {
    userName.value = '$provider Felhasználó';
    userEmail.value = 'user@$provider.com'.toLowerCase();
    isPartner.value = false;
    isLoggedIn.value = true;
  }

  /// Kijelentkezés
  static void logout() {
    isLoggedIn.value = false;
    userEmail.value = '';
    userName.value = '';
    isPartner.value = false;
  }
}