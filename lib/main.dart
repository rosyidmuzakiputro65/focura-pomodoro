import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app.dart';
import 'core/config/firebase_config.dart';
import 'core/services/focus_audio_service.dart';
import 'core/services/notification_service_factory.dart';
import 'core/storage/local_database.dart';
import 'features/auth/data/repositories/firebase_auth_repository.dart';
import 'features/auth/data/repositories/local_auth_repository.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/music/data/repositories/local_music_repository.dart';
import 'features/quotes/data/datasources/quote_cache.dart';
import 'features/quotes/data/datasources/quote_remote_data_source.dart';
import 'features/quotes/data/datasources/translation_remote_data_source.dart';
import 'features/quotes/data/repositories/quote_repository_impl.dart';
import 'features/quotes/data/repositories/translation_repository_impl.dart';
import 'features/settings/data/repositories/local_settings_repository.dart';
import 'features/stats/data/repositories/firestore_session_repository.dart';
import 'features/stats/data/repositories/local_session_repository.dart';
import 'features/stats/domain/repositories/session_repository.dart';
import 'features/tasks/data/repositories/firestore_task_repository.dart';
import 'features/tasks/data/repositories/local_task_repository.dart';
import 'features/tasks/domain/repositories/task_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalDatabase.init();

  final notificationService = createNotificationService();
  await notificationService.init();

  final backend = await _createBackend();

  final httpClient = http.Client();

  runApp(
    FocuraApp(
      dependencies: AppDependencies(
        authRepository: backend.auth,
        taskRepository: backend.tasks,
        quoteRepository: QuoteRepositoryImpl(
          remote: QuoteRemoteDataSource(client: httpClient),
          cache: HiveQuoteCache(LocalDatabase.box(LocalDatabase.quotesCacheBox)),
        ),
        settingsRepository: LocalSettingsRepository(
          LocalDatabase.box(LocalDatabase.settingsBox),
        ),
        sessionRepository: backend.sessions,
        notificationService: notificationService,
        translationRepository: TranslationRepositoryImpl(
          remote: TranslationRemoteDataSource(client: httpClient),
          cache: LocalDatabase.box(LocalDatabase.translationsCacheBox),
        ),
        musicRepository: LocalMusicRepository(
          LocalDatabase.box(LocalDatabase.settingsBox),
        ),
        audioService: AudioplayersFocusAudioService(),
        systemLanguageCode:
            WidgetsBinding.instance.platformDispatcher.locale.languageCode,
      ),
    ),
  );
}

class _Backend {
  const _Backend(this.auth, this.tasks, this.sessions);

  final AuthRepository auth;
  final TaskRepository tasks;
  final SessionRepository sessions;
}

/// Backend cloud (Firebase Auth + Firestore) jika konfigurasi tersedia,
/// selain itu database lokal Hive (aplikasi tetap bisa dipakai tanpa internet
/// atau saat dijalankan tanpa `firebase_config.json`).
Future<_Backend> _createBackend() async {
  if (FirebaseConfig.isConfigured) {
    try {
      await Firebase.initializeApp(options: FirebaseConfig.currentPlatform);
      final firestore = FirebaseFirestore.instance;
      // Cache offline Firestore (otomatis di Android/iOS, perlu diaktifkan di web).
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      debugPrint('Backend: Firebase (${FirebaseConfig.projectId})');
      return _Backend(
        FirebaseAuthRepository(auth: FirebaseAuth.instance, firestore: firestore),
        FirestoreTaskRepository(firestore),
        FirestoreSessionRepository(firestore),
      );
    } catch (error) {
      debugPrint('Firebase gagal diinisialisasi, memakai database lokal: $error');
    }
  }
  debugPrint('Backend: database lokal (Hive)');
  final localAuth = LocalAuthRepository(
    usersBox: LocalDatabase.box(LocalDatabase.usersBox),
    sessionBox: LocalDatabase.box(LocalDatabase.sessionBox),
  );
  await localAuth.ensureDemoAccount();
  return _Backend(
    localAuth,
    LocalTaskRepository(LocalDatabase.box(LocalDatabase.tasksBox)),
    LocalSessionRepository(LocalDatabase.box(LocalDatabase.focusSessionsBox)),
  );
}
