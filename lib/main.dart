import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app.dart';
import 'core/services/focus_audio_service.dart';
import 'core/services/notification_service_factory.dart';
import 'core/storage/local_database.dart';
import 'features/auth/data/repositories/local_auth_repository.dart';
import 'features/music/data/repositories/local_music_repository.dart';
import 'features/quotes/data/datasources/quote_cache.dart';
import 'features/quotes/data/datasources/quote_remote_data_source.dart';
import 'features/quotes/data/datasources/translation_remote_data_source.dart';
import 'features/quotes/data/repositories/quote_repository_impl.dart';
import 'features/quotes/data/repositories/translation_repository_impl.dart';
import 'features/settings/data/repositories/local_settings_repository.dart';
import 'features/stats/data/repositories/local_session_repository.dart';
import 'features/tasks/data/repositories/local_task_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalDatabase.init();

  final notificationService = createNotificationService();
  await notificationService.init();

  final authRepository = LocalAuthRepository(
    usersBox: LocalDatabase.box(LocalDatabase.usersBox),
    sessionBox: LocalDatabase.box(LocalDatabase.sessionBox),
  );
  await authRepository.ensureDemoAccount();

  final httpClient = http.Client();

  runApp(
    FocuraApp(
      dependencies: AppDependencies(
        authRepository: authRepository,
        taskRepository: LocalTaskRepository(
          LocalDatabase.box(LocalDatabase.tasksBox),
        ),
        quoteRepository: QuoteRepositoryImpl(
          remote: QuoteRemoteDataSource(client: httpClient),
          cache: HiveQuoteCache(LocalDatabase.box(LocalDatabase.quotesCacheBox)),
        ),
        settingsRepository: LocalSettingsRepository(
          LocalDatabase.box(LocalDatabase.settingsBox),
        ),
        sessionRepository: LocalSessionRepository(
          LocalDatabase.box(LocalDatabase.focusSessionsBox),
        ),
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
