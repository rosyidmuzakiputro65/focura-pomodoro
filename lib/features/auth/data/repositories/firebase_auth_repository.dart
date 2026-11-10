import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/config/firebase_config.dart';
import '../../../../core/constants/demo_account.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/firebase/firebase_error_mapper.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Autentikasi dengan Firebase Authentication (email & password).
/// Profil pengguna juga disimpan di Firestore: `users/{uid}`.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({required this._auth, required this._firestore});

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<AppUser?> currentUser() async {
    // Di web, sesi dipulihkan secara asinkron: tunggu event pertama.
    final user = _auth.currentUser ?? await _auth.authStateChanges().first;
    return user == null ? null : _toAppUser(user);
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Validasi sebelum data dikirim ke server.
    final error =
        Validators.name(name) ??
        Validators.email(email) ??
        Validators.newPassword(password);
    if (error != null) throw ValidationException(error);
    try {
      return await _createAccount(name.trim(), email.trim(), password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(mapFirebaseErrorCode(e.code));
    }
  }

  @override
  Future<AppUser> login({required String email, required String password}) async {
    final error = Validators.email(email) ?? Validators.requiredPassword(password);
    if (error != null) throw ValidationException(error);
    final normalized = email.trim().toLowerCase();
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: normalized,
        password: password,
      );
      return _toAppUser(result.user!);
    } on FirebaseAuthException catch (e) {
      final mapped = mapFirebaseErrorCode(e.code);
      // Akun demo dibuat otomatis saat pertama kali dipakai.
      if (mapped == AppError.wrongCredentials &&
          normalized == DemoAccount.email &&
          password == DemoAccount.password) {
        try {
          return await _createAccount(
            DemoAccount.name,
            DemoAccount.email,
            DemoAccount.password,
          );
        } on FirebaseAuthException catch (e2) {
          throw AuthException(mapFirebaseErrorCode(e2.code));
        }
      }
      throw AuthException(mapped);
    }
  }

  static bool _googleInitialized = false;

  /// Web: popup Google dari Firebase Auth.
  /// Android: paket google_sign_in (butuh SHA-1 terdaftar di Firebase).
  @override
  Future<AppUser> loginWithGoogle() async {
    try {
      final UserCredential result;
      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..setCustomParameters({'prompt': 'select_account'});
        result = await _auth.signInWithPopup(provider);
      } else {
        final google = GoogleSignIn.instance;
        if (!_googleInitialized) {
          await google.initialize(
            serverClientId: FirebaseConfig.googleWebClientId.isEmpty
                ? null
                : FirebaseConfig.googleWebClientId,
          );
          _googleInitialized = true;
        }
        final account = await google.authenticate();
        final idToken = account.authentication.idToken;
        if (idToken == null) {
          throw const AuthException(AppError.googleSignInFailed);
        }
        result = await _auth.signInWithCredential(
          GoogleAuthProvider.credential(idToken: idToken),
        );
      }
      final user = result.user!;
      final appUser = _toAppUser(user);
      await _saveProfile(user.uid, appUser.name, appUser.email);
      return appUser;
    } on GoogleSignInException catch (e) {
      debugPrint('Google sign-in error: ${e.code} ${e.description}');
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException(AppError.signInCancelled);
      }
      throw const AuthException(AppError.googleSignInFailed);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        throw const AuthException(AppError.signInCancelled);
      }
      final mapped = mapFirebaseErrorCode(e.code);
      throw AuthException(
        mapped == AppError.unknown ? AppError.googleSignInFailed : mapped,
      );
    }
  }

  /// Simpan/perbarui profil `users/{uid}` (nama 3-50 karakter sesuai rules).
  Future<void> _saveProfile(String uid, String name, String email) async {
    var safeName = name.trim();
    if (safeName.length < 3) safeName = email.split('@').first.padRight(3, '_');
    if (safeName.length > 50) safeName = safeName.substring(0, 50);
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set({
            'name': safeName,
            'email': email,
            'createdAt': Timestamp.fromDate(DateTime.now()),
          }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 5));
    } catch (error) {
      debugPrint('Profil belum tersimpan: $error');
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    if (!kIsWeb && _googleInitialized) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
    }
  }

  Future<AppUser> _createAccount(String name, String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email.toLowerCase(),
      password: password,
    );
    final user = result.user!;
    await user.updateDisplayName(name);
    final now = DateTime.now();
    // Profil di Firestore (tidak menunggu server jika sedang offline).
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set({
          'name': name,
          'email': email.toLowerCase(),
          'createdAt': Timestamp.fromDate(now),
        })
        .timeout(const Duration(seconds: 5), onTimeout: () {});
    return AppUser(
      id: user.uid,
      name: name,
      email: email.toLowerCase(),
      createdAt: now,
    );
  }

  AppUser _toAppUser(User user) {
    final email = user.email ?? '';
    final name = (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName!.trim()
        : email.split('@').first;
    return AppUser(
      id: user.uid,
      name: name,
      email: email,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }
}
