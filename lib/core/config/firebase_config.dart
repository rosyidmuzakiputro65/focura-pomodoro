import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Konfigurasi Firebase dibaca saat build lewat
/// `--dart-define-from-file=firebase_config.json` (file tidak di-commit).
/// Jika kosong, aplikasi otomatis memakai database lokal (Hive).
class FirebaseConfig {
  const FirebaseConfig._();

  static const String apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const String storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );
  static const String authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const String webAppId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
  static const String androidAppId = String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
  );
  static const String androidApiKey = String.fromEnvironment(
    'FIREBASE_ANDROID_API_KEY',
  );

  /// OAuth "Web client ID" (client_type 3 di google-services.json),
  /// dibutuhkan Google Sign-In di Android.
  static const String googleWebClientId = String.fromEnvironment(
    'FIREBASE_GOOGLE_WEB_CLIENT_ID',
  );

  /// `true` jika konfigurasi untuk platform yang sedang berjalan tersedia.
  static bool get isConfigured {
    if (apiKey.isEmpty || projectId.isEmpty || messagingSenderId.isEmpty) {
      return false;
    }
    if (kIsWeb) return webAppId.isNotEmpty;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => androidAppId.isNotEmpty,
      _ => false, // iOS/desktop belum didaftarkan -> mode lokal
    };
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: apiKey,
        appId: webAppId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        authDomain: authDomain,
        storageBucket: storageBucket,
      );
    }
    return FirebaseOptions(
      apiKey: androidApiKey.isNotEmpty ? androidApiKey : apiKey,
      appId: androidAppId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      storageBucket: storageBucket,
    );
  }
}
