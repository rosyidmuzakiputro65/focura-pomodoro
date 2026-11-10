import 'package:flutter/foundation.dart';

import '../errors/app_exception.dart';

/// Mengubah kode error Firebase (Auth & Firestore) menjadi [AppError]
/// agar pesannya bisa diterjemahkan di UI.
AppError mapFirebaseErrorCode(String code) {
  debugPrint('Firebase error: $code');
  return _map(code);
}

AppError _map(String code) => switch (code) {
  'email-already-in-use' => AppError.emailAlreadyRegistered,
  'invalid-email' => AppError.emailInvalid,
  'weak-password' => AppError.passwordWeak,
  'user-not-found' ||
  'wrong-password' ||
  'invalid-credential' ||
  'INVALID_LOGIN_CREDENTIALS' => AppError.wrongCredentials,
  'too-many-requests' => AppError.tooManyAttempts,
  'network-request-failed' || 'unavailable' => AppError.networkOffline,
  'deadline-exceeded' => AppError.networkTimeout,
  'permission-denied' || 'unauthenticated' => AppError.permissionDenied,
  'not-found' => AppError.taskNotFound,
  // Email/Password belum diaktifkan di Firebase Console.
  'operation-not-allowed' || 'configuration-not-found' =>
    AppError.authProviderDisabled,
  _ => AppError.unknown,
};
