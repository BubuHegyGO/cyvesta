import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

/// Egy hitelesítési művelet eredménye: sikeres, megszakított vagy hibás (érthető üzenettel).
class AuthResult {
  final bool success;
  final bool cancelled;
  final String? message;
  final bool verificationEmailSent;

  const AuthResult._({
    required this.success,
    this.cancelled = false,
    this.message,
    this.verificationEmailSent = false,
  });

  const AuthResult.ok({bool verificationEmailSent = false})
      : this._(success: true, verificationEmailSent: verificationEmailSent);

  const AuthResult.userCancelled() : this._(success: false, cancelled: true);

  const AuthResult.error(String message) : this._(success: false, message: message);
}

class AuthState {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static StreamSubscription<User?>? _authSub;

  /// A bejelentkezett felhasználó Firebase UID-ja (null, ha nincs bejelentkezve).
  static String? get currentUserId => _auth.currentUser?.uid;

  static final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  static final ValueNotifier<String> userName = ValueNotifier<String>('');
  static final ValueNotifier<String> userEmail = ValueNotifier<String>('');
  /// Igaz, ha a felhasználó céges partner-jelentkezését az admin jóváhagyta (`partners/{uid}.status == approved`).
  static final ValueNotifier<bool> isPartner = ValueNotifier<bool>(false);

  /// A partner-jelentkezés állapota: none, pending, approved vagy rejected.
  static final ValueNotifier<String> partnerStatus = ValueNotifier<String>('none');

  /// Az automatikus ellenőrzés (VIES / admin) üzenete a partner-jelentkezéshez.
  static final ValueNotifier<String> partnerNote = ValueNotifier<String>('');

  /// Igaz, ha a bejelentkezett felhasználónak van dokumentuma az `admins/{uid}` gyűjteményben.
  /// A dokumentumot csak a Firebase konzolban lehet létrehozni (a Security Rules tiltja az appból).
  static final ValueNotifier<bool> isAdmin = ValueNotifier<bool>(false);

  /// Betölti a szerepköröket a Firestore-ból: admin-e (`admins/{uid}`) és partner-e (`partners/{uid}`).
  /// A döntést a Security Rules hozza meg, ez csak a felület megjelenítéséhez kell.
  static Future<void> refreshRoles() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      isAdmin.value = false;
      isPartner.value = false;
      partnerStatus.value = 'none';
      partnerNote.value = '';
      return;
    }

    try {
      final db = FirebaseFirestore.instance;
      final results = await Future.wait([
        db.collection('admins').doc(uid).get(),
        db.collection('partners').doc(uid).get(),
      ]);

      // Csak akkor érvényes az eredmény, ha közben nem váltott fiókot.
      if (_auth.currentUser?.uid != uid) return;

      isAdmin.value = results[0].exists;

      final dynamic rawStatus = results[1].data()?['status'];
      final String status = rawStatus is String ? rawStatus : 'none';
      partnerStatus.value = status;
      isPartner.value = status == 'approved';
      final verification = results[1].data()?['verification'];
      partnerNote.value = (verification is Map ? verification['reason']?.toString() : null) ?? '';
    } catch (e) {
      debugPrint('Szerepkör ellenőrzési hiba: $e');
      if (_auth.currentUser?.uid == uid) {
        isAdmin.value = false;
        isPartner.value = false;
        partnerStatus.value = 'none';
      }
    }
  }

  /// A main()-ben kell meghívni a Firebase inicializálása UTÁN.
  static void init() {
    _authSub?.cancel();
    _authSub = _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        isLoggedIn.value = true;
        userEmail.value = user.email ?? '';
        userName.value = user.displayName ?? (user.email?.split('@').first ?? 'Felhasználó');
        refreshRoles();
      } else {
        isLoggedIn.value = false;
        isAdmin.value = false;
        isPartner.value = false;
        partnerStatus.value = 'none';
        userName.value = '';
        userEmail.value = '';
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Hibaüzenetek
  // ---------------------------------------------------------------------------

  static String _messageFor(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Érvénytelen e-mail cím.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-login-credentials':
          return 'Hibás e-mail vagy jelszó.';
        case 'email-already-in-use':
          return 'Ezzel az e-mail címmel már létezik fiók. Próbálj bejelentkezni, vagy kérj új jelszót.';
        case 'weak-password':
          return 'A jelszó túl gyenge, legalább 6 karakter szükséges.';
        case 'network-request-failed':
          return 'Nincs internetkapcsolat. Ellenőrizd a hálózatot, és próbáld újra.';
        case 'too-many-requests':
          return 'Túl sok próbálkozás. Várj egy kicsit, majd próbáld újra.';
        case 'user-disabled':
          return 'Ezt a fiókot letiltották.';
        case 'account-exists-with-different-credential':
          return 'Ezzel az e-mail címmel már van fiók egy másik belépési móddal (pl. Google vagy jelszó). Azzal lépj be.';
        case 'operation-not-allowed':
          return 'Ez a belépési mód jelenleg nincs engedélyezve.';
      }
    }
    return 'Ismeretlen hiba történt. Próbáld újra később.';
  }

  static bool _isCancel(Object error) {
    if (error is FirebaseAuthException) {
      return const {
        'canceled',
        'cancelled',
        'web-context-canceled',
        'popup-closed-by-user',
        'user-cancelled',
      }.contains(error.code);
    }
    if (error is SignInWithAppleAuthorizationException) {
      return error.code == AuthorizationErrorCode.canceled;
    }
    return false;
  }

  static AuthResult _failure(Object error) {
    if (_isCancel(error)) return const AuthResult.userCancelled();
    return AuthResult.error(_messageFor(error));
  }

  // ---------------------------------------------------------------------------
  // E-mail & jelszó
  // ---------------------------------------------------------------------------

  static Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required bool asPartner,
  }) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      isLoggedIn.value = true;
      userEmail.value = email;
      userName.value = name;
      // A partner státuszt nem a kliens dönti el: azt a Firestore `partners` gyűjtemény adja,
      // a jelentkezést a submitPartnerApplication() menti, a jóváhagyást az admin végzi.

      // A visszaigazoló e-mail hibája nem akadályozza meg a regisztrációt.
      bool verificationSent = false;
      try {
        await credential.user?.sendEmailVerification();
        verificationSent = true;
      } catch (e) {
        debugPrint('Visszaigazoló e-mail küldési hiba: $e');
      }

      return AuthResult.ok(verificationEmailSent: verificationSent);
    } catch (e) {
      debugPrint('Firebase regisztrációs hiba: $e');
      return _failure(e);
    }
  }

  static Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      isLoggedIn.value = true;
      userEmail.value = email;
      userName.value = credential.user?.displayName ?? email.split('@').first;

      return const AuthResult.ok();
    } catch (e) {
      debugPrint('Firebase bejelentkezési hiba: $e');
      return _failure(e);
    }
  }

  // ---------------------------------------------------------------------------
  // E-mail megerősítés
  // ---------------------------------------------------------------------------

  /// Igaz, ha a felhasználó jelszavas fiókkal lépett be, és az e-mail címét még nem erősítette meg.
  /// (A Google/Apple/Facebook fiókokra nem vonatkozik.)
  static bool get needsEmailVerification {
    final user = _auth.currentUser;
    if (user == null) return false;
    final usesPassword = user.providerData.any((p) => p.providerId == 'password');
    return usesPassword && !user.emailVerified;
  }

  static Future<AuthResult> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return const AuthResult.error('Nem vagy bejelentkezve.');
      await user.sendEmailVerification();
      return const AuthResult.ok(verificationEmailSent: true);
    } catch (e) {
      debugPrint('Visszaigazoló e-mail küldési hiba: $e');
      return AuthResult.error(_messageFor(e));
    }
  }

  /// Újratölti a fiókot a Firebase-ből. Igaz, ha már nincs szükség megerősítésre.
  static Future<bool> refreshAndCheckVerified() async {
    try {
      await _auth.currentUser?.reload();
      // A Firestore Security Rules az ID tokenből olvassa az email_verified értéket,
      // ezért a tokent is frissíteni kell, különben "permission-denied" hibát kapnánk.
      await _auth.currentUser?.getIdToken(true);
    } catch (e) {
      debugPrint('Fiók frissítési hiba: $e');
    }
    return !needsEmailVerification;
  }

  // ---------------------------------------------------------------------------
  // Jelszó-visszaállítás
  // ---------------------------------------------------------------------------

  static Future<AuthResult> sendPasswordReset(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return const AuthResult.error('Add meg az e-mail címedet.');
    try {
      await _auth.sendPasswordResetEmail(email: trimmed);
      return const AuthResult.ok();
    } on FirebaseAuthException catch (e) {
      // Nem áruljuk el, hogy létezik-e fiók az adott címmel.
      if (e.code == 'user-not-found') return const AuthResult.ok();
      debugPrint('Jelszó-visszaállítási hiba: $e');
      return AuthResult.error(_messageFor(e));
    } catch (e) {
      debugPrint('Jelszó-visszaállítási hiba: $e');
      return AuthResult.error(_messageFor(e));
    }
  }

  // ---------------------------------------------------------------------------
  // Közösségi bejelentkezés
  // ---------------------------------------------------------------------------

  // Valós Apple Bejelentkezés Firebase-ben (Android webAuthenticationOptions-szal)
  static Future<AuthResult> loginWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.cyvesta.app',
          redirectUri: Uri.parse(
            'https://cyvesta-ad506.firebaseapp.com/__/auth/handler',
          ),
        ),
      );

      final OAuthProvider provider = OAuthProvider('apple.com');
      final AuthCredential credential = provider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      isLoggedIn.value = true;
      userEmail.value = userCredential.user?.email ?? appleCredential.email ?? '';
      userName.value = userCredential.user?.displayName ??
          ((appleCredential.givenName != null || appleCredential.familyName != null)
              ? '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim()
              : 'Apple Felhasználó');

      return const AuthResult.ok();
    } catch (e) {
      debugPrint('Apple bejelentkezési hiba: $e');
      return _failure(e);
    }
  }

  // Valós Google Bejelentkezés Firebase-ben (extra csomag nélkül)
  static Future<AuthResult> loginWithGoogle() async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithProvider(GoogleAuthProvider());

      isLoggedIn.value = true;
      userEmail.value = userCredential.user?.email ?? '';
      userName.value = userCredential.user?.displayName ?? 'Google Felhasználó';

      return const AuthResult.ok();
    } catch (e) {
      debugPrint('Google bejelentkezési hiba: $e');
      return _failure(e);
    }
  }

  // Valós Facebook Bejelentkezés Firebase-ben
  static Future<AuthResult> loginWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.cancelled) {
        return const AuthResult.userCancelled();
      }
      if (result.status != LoginStatus.success || result.accessToken == null) {
        debugPrint('Facebook bejelentkezés sikertelen: ${result.status}');
        return const AuthResult.error('A Facebook bejelentkezés nem sikerült. Próbáld újra.');
      }

      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.tokenString);
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      isLoggedIn.value = true;
      userEmail.value = userCredential.user?.email ?? '';
      userName.value = userCredential.user?.displayName ?? 'Facebook Felhasználó';

      return const AuthResult.ok();
    } catch (e) {
      debugPrint('Facebook bejelentkezési hiba: $e');
      return _failure(e);
    }
  }

  // Céges partner jelentkezés mentése. A jelentkezés mindig "pending" állapotban jön létre,
  // jóváhagyni csak az admin tudja (a Security Rules ezt kikényszeríti).
  static Future<AuthResult> submitPartnerApplication({
    required String companyName,
    required String regType, // 'HE' vagy 'VAT'
    required String regNumber,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const AuthResult.error('Nem vagy bejelentkezve.');

    try {
      await FirebaseFirestore.instance.collection('partners').doc(uid).set({
        'status': 'pending',
        'companyName': companyName,
        'regType': regType,
        'regNumber': regNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });
      partnerStatus.value = 'pending';
      return const AuthResult.ok();
    } catch (e) {
      debugPrint('Partner jelentkezés mentési hiba: $e');
      return const AuthResult.error('A partner jelentkezés mentése nem sikerült. Próbáld újra később.');
    }
  }

  // Kijelentkezés
  static Future<void> logout() async {
    await _auth.signOut();
    await FacebookAuth.instance.logOut(); // Facebook session tisztítása is
    isLoggedIn.value = false;
    userName.value = '';
    userEmail.value = '';
    isPartner.value = false;
    partnerStatus.value = 'none';
    isAdmin.value = false;
  }
}
