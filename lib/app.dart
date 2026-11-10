import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/l10n/app_strings.dart';
import 'core/router/app_routes.dart';
import 'core/services/focus_audio_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/music/domain/repositories/music_repository.dart';
import 'features/music/presentation/cubit/focus_music_cubit.dart';
import 'features/quotes/domain/repositories/quote_repository.dart';
import 'features/quotes/domain/repositories/translation_repository.dart';
import 'features/quotes/presentation/cubit/quote_cubit.dart';
import 'features/quotes/presentation/cubit/quote_translation_cubit.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/stats/domain/repositories/session_repository.dart';
import 'features/stats/presentation/cubit/stats_cubit.dart';
import 'features/tasks/domain/repositories/task_repository.dart';
import 'features/tasks/presentation/cubit/task_cubit.dart';
import 'features/timer/presentation/cubit/pomodoro_cubit.dart';

/// Semua dependensi aplikasi (dependency injection manual).
class AppDependencies {
  const AppDependencies({
    required this.authRepository,
    required this.taskRepository,
    required this.quoteRepository,
    required this.settingsRepository,
    required this.sessionRepository,
    required this.notificationService,
    required this.translationRepository,
    required this.musicRepository,
    required this.audioService,
    this.systemLanguageCode,
  });

  final AuthRepository authRepository;
  final TaskRepository taskRepository;
  final QuoteRepository quoteRepository;
  final SettingsRepository settingsRepository;
  final SessionRepository sessionRepository;
  final NotificationService notificationService;
  final TranslationRepository translationRepository;
  final MusicRepository musicRepository;
  final FocusAudioService audioService;

  /// Bahasa perangkat, dipakai jika pengguna belum memilih bahasa.
  final String? systemLanguageCode;
}

class FocuraApp extends StatefulWidget {
  const FocuraApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<FocuraApp> createState() => _FocuraAppState();
}

class _FocuraAppState extends State<FocuraApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _applyLanguage(BuildContext context, String languageCode) {
    final s = AppStrings.forLanguageCode(languageCode);
    widget.dependencies.notificationService.setChannelText(
      name: s.notifChannelName,
      description: s.notifChannelDescription,
    );
    context.read<PomodoroCubit>().setNotificationCopy(
      SessionNotificationCopy(
        focusDoneTitle: s.notifFocusTitle,
        focusDoneBody: s.notifFocusBody,
        breakDoneTitle: s.notifBreakTitle,
        breakDoneBody: s.notifBreakBody,
      ),
    );
  }

  void _go(String route) {
    _navigatorKey.currentState?.pushNamedAndRemoveUntil(route, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final deps = widget.dependencies;
    return RepositoryProvider<NotificationService>.value(
      value: deps.notificationService,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthCubit(deps.authRepository)),
          BlocProvider(
            create: (_) => SettingsCubit(
              deps.settingsRepository,
              systemLanguageCode: deps.systemLanguageCode,
            ),
          ),
          BlocProvider(create: (_) => TaskCubit(deps.taskRepository)),
          BlocProvider(create: (_) => StatsCubit(deps.sessionRepository)),
          BlocProvider(create: (_) => QuoteCubit(deps.quoteRepository)),
          BlocProvider(
            create: (_) => QuoteTranslationCubit(deps.translationRepository),
          ),
          BlocProvider(
            create: (_) => FocusMusicCubit(
              audio: deps.audioService,
              repository: deps.musicRepository,
            )..load(),
          ),
          BlocProvider(
            create: (_) {
              final s = AppStrings.forLanguageCode(
                deps.systemLanguageCode ?? 'id',
              );
              return PomodoroCubit(
                notifications: deps.notificationService,
                notificationCopy: SessionNotificationCopy(
                  focusDoneTitle: s.notifFocusTitle,
                  focusDoneBody: s.notifFocusBody,
                  breakDoneTitle: s.notifBreakTitle,
                  breakDoneBody: s.notifBreakBody,
                ),
              );
            },
          ),
        ],
        child: MultiBlocListener(
          listeners: [
            // Navigasi otomatis saat login / logout + memuat data milik user.
            BlocListener<AuthCubit, AuthState>(
              listenWhen: (p, c) =>
                  c.status != AuthStatus.unknown &&
                  (p.status != c.status || p.user?.id != c.user?.id),
              listener: (context, state) {
                final userId = state.user?.id;
                context.read<TaskCubit>().setUser(userId);
                context.read<StatsCubit>().setUser(userId);
                if (state.status == AuthStatus.authenticated) {
                  _go(AppRoutes.home);
                } else {
                  context.read<PomodoroCubit>().resetAll();
                  context.read<FocusMusicCubit>().stopAll();
                  _go(AppRoutes.login);
                }
              },
            ),
            // Musik penenang mengikuti status timer (mulai fokus -> putar).
            BlocListener<PomodoroCubit, PomodoroState>(
              listenWhen: (p, c) =>
                  p.isRunning != c.isRunning || p.mode != c.mode,
              listener: (context, state) {
                context.read<FocusMusicCubit>().onTimerChanged(
                  isRunning: state.isRunning,
                  isFocusMode: state.mode == PomodoroMode.focus,
                );
              },
            ),
            // Teks notifikasi mengikuti bahasa yang dipilih.
            BlocListener<SettingsCubit, SettingsState>(
              listenWhen: (p, c) => p.languageCode != c.languageCode,
              listener: (context, state) =>
                  _applyLanguage(context, state.languageCode),
            ),
            // Durasi timer mengikuti pengaturan pengguna.
            BlocListener<SettingsCubit, SettingsState>(
              listenWhen: (p, c) => p.timer != c.timer,
              listener: (context, state) {
                context.read<PomodoroCubit>().updateDurations(
                  focus: state.timer.focus,
                  shortBreak: state.timer.shortBreak,
                  longBreak: state.timer.longBreak,
                );
              },
            ),
          ],
          // MaterialApp dibangun ulang saat bahasa diganti.
          child: BlocBuilder<SettingsCubit, SettingsState>(
            buildWhen: (p, c) => p.languageCode != c.languageCode,
            builder: (context, settings) => MaterialApp(
            onGenerateTitle: (context) => AppStrings.of(context).appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            locale: settings.locale,
            supportedLocales: AppStrings.supportedLocales,
            localizationsDelegates: const [
              AppStrings.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            navigatorKey: _navigatorKey,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            // Selalu mulai dari splash (cek onboarding & sesi login), termasuk
            // saat halaman web di-reload pada URL seperti /#/home.
            onGenerateInitialRoutes: (_) => [
              AppRoutes.onGenerateRoute(
                const RouteSettings(name: AppRoutes.splash),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
