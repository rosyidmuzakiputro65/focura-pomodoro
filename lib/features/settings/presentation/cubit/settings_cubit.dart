import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../domain/entities/timer_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.timer = const TimerSettings(),
    this.onboardingDone = false,
    this.isLoaded = false,
    this.languageCode = 'id',
  });

  final TimerSettings timer;
  final bool onboardingDone;
  final bool isLoaded;

  /// Bahasa aplikasi: `id` (Indonesia) atau `en` (English).
  final String languageCode;

  Locale get locale => Locale(languageCode);

  SettingsState copyWith({
    TimerSettings? timer,
    bool? onboardingDone,
    bool? isLoaded,
    String? languageCode,
  }) {
    return SettingsState(
      timer: timer ?? this.timer,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      isLoaded: isLoaded ?? this.isLoaded,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  List<Object?> get props => [timer, onboardingDone, isLoaded, languageCode];
}

class SettingsCubit extends Cubit<SettingsState> {
  /// [systemLanguageCode] dipakai sebagai bahasa awal jika pengguna belum
  /// pernah memilih bahasa (dan bahasanya didukung).
  SettingsCubit(this._repository, {String? systemLanguageCode})
    : super(
        SettingsState(
          languageCode: _supportedOrDefault(systemLanguageCode),
        ),
      );

  final SettingsRepository _repository;

  static String _supportedOrDefault(String? code) =>
      code != null && AppStrings.isSupported(code) ? code : 'id';

  Future<void> load() async {
    final timer = await _repository.loadTimerSettings();
    final onboardingDone = await _repository.isOnboardingDone();
    final savedLanguage = await _repository.loadLanguageCode();
    emit(
      state.copyWith(
        timer: timer,
        onboardingDone: onboardingDone,
        isLoaded: true,
        languageCode: savedLanguage != null && AppStrings.isSupported(savedLanguage)
            ? savedLanguage
            : null,
      ),
    );
  }

  Future<void> completeOnboarding() async {
    await _repository.setOnboardingDone();
    emit(state.copyWith(onboardingDone: true));
  }

  Future<void> changeLanguage(String code) async {
    if (!AppStrings.isSupported(code) || code == state.languageCode) return;
    await _repository.saveLanguageCode(code);
    emit(state.copyWith(languageCode: code));
  }

  /// Mengembalikan `null` jika berhasil, atau kode error validasi.
  Future<AppError?> updateTimer(TimerSettings settings) async {
    try {
      await _repository.saveTimerSettings(settings);
      emit(state.copyWith(timer: settings));
      return null;
    } on AppException catch (error) {
      return error.error;
    }
  }
}
