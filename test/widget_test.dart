import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/l10n/app_strings.dart';
import 'package:flutter_application_1/core/services/focus_audio_service.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/features/auth/domain/entities/app_user.dart';
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_application_1/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_application_1/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_application_1/features/music/presentation/cubit/focus_music_cubit.dart';
import 'package:flutter_application_1/features/quotes/presentation/cubit/quote_cubit.dart';
import 'package:flutter_application_1/features/quotes/presentation/cubit/quote_translation_cubit.dart';
import 'package:flutter_application_1/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_application_1/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:flutter_application_1/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:flutter_application_1/features/timer/presentation/cubit/pomodoro_cubit.dart';
import 'package:flutter_application_1/features/timer/presentation/pages/pomodoro_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';

class _NeverCalledAuthRepository implements AuthRepository {
  int loginCalls = 0;

  @override
  Future<AppUser?> currentUser() async => null;

  @override
  Future<AppUser> login({required String email, required String password}) async {
    loginCalls++;
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) => throw UnimplementedError();
}

/// MaterialApp yang bahasanya mengikuti SettingsCubit, sama seperti app.dart.
Widget _localizedApp(Widget home) {
  return BlocBuilder<SettingsCubit, SettingsState>(
    builder: (context, settings) => MaterialApp(
      theme: AppTheme.darkTheme,
      locale: settings.locale,
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: const [
        AppStrings.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    ),
  );
}

void main() {
  testWidgets('Login: form kosong menampilkan pesan validasi', (tester) async {
    final repo = _NeverCalledAuthRepository();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthCubit(repo)),
          BlocProvider(create: (_) => SettingsCubit(InMemorySettingsRepository())),
        ],
        child: _localizedApp(const LoginPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);
    expect(repo.loginCalls, 0);
  });

  testWidgets('Ganti bahasa ke English mengubah teks dan pesan validasi', (
    tester,
  ) async {
    final settingsRepo = InMemorySettingsRepository();
    final settings = SettingsCubit(settingsRepo);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthCubit(_NeverCalledAuthRepository())),
          BlocProvider.value(value: settings),
        ],
        child: _localizedApp(const LoginPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang kembali'), findsOneWidget);

    // Pilih English lewat tombol bahasa.
    await tester.tap(find.byKey(const Key('language_button')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(CheckedPopupMenuItem<String>, 'English'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(settingsRepo.languageCode, 'en');

    await tester.tap(find.text('Sign in'));
    await tester.pump();
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);

    await settings.close();
  });

  testWidgets('Timer: menampilkan 25:00 dan bisa dimulai', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final pomodoro = PomodoroCubit();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: pomodoro),
          BlocProvider(create: (_) => SettingsCubit(InMemorySettingsRepository())),
          BlocProvider(create: (_) => StatsCubit(InMemorySessionRepository())),
          BlocProvider(create: (_) => TaskCubit(InMemoryTaskRepository())),
          BlocProvider(create: (_) => QuoteCubit(FakeQuoteRepository())),
          BlocProvider(
            create: (_) => QuoteTranslationCubit(FakeTranslationRepository()),
          ),
          BlocProvider(
            create: (_) => FocusMusicCubit(
              audio: SilentFocusAudioService(),
              repository: InMemoryMusicRepository(),
            ),
          ),
        ],
        child: _localizedApp(const PomodoroPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Mulai fokus'), findsOneWidget);
    expect(find.text('Musik penenang'), findsOneWidget);
    expect(find.text('Piano Tenang'), findsOneWidget);

    final toggle = find.byKey(const Key('timer_toggle'));
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pump();

    expect(find.text('Jeda'), findsOneWidget);

    pomodoro.pause();
    await tester.pumpWidget(const SizedBox());
    await pomodoro.close();
  });
}
