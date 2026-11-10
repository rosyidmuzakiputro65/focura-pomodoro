import 'package:hive_ce/hive.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/timer_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this._box);

  final Box<dynamic> _box;

  static const String _focusKey = 'focusMinutes';
  static const String _shortKey = 'shortBreakMinutes';
  static const String _longKey = 'longBreakMinutes';
  static const String _onboardingKey = 'onboardingDone';
  static const String _languageKey = 'languageCode';
  static const Set<String> _supportedLanguages = {'id', 'en'};

  @override
  Future<TimerSettings> loadTimerSettings() async {
    const defaults = TimerSettings();
    return TimerSettings(
      focusMinutes: (_box.get(_focusKey) as int?) ?? defaults.focusMinutes,
      shortBreakMinutes:
          (_box.get(_shortKey) as int?) ?? defaults.shortBreakMinutes,
      longBreakMinutes: (_box.get(_longKey) as int?) ?? defaults.longBreakMinutes,
    );
  }

  @override
  Future<void> saveTimerSettings(TimerSettings settings) async {
    final error =
        Validators.durationMinutes(settings.focusMinutes, min: 5, max: 90) ??
        Validators.durationMinutes(settings.shortBreakMinutes, min: 1, max: 30) ??
        Validators.durationMinutes(settings.longBreakMinutes, min: 5, max: 60);
    if (error != null) throw ValidationException(error);
    await _box.putAll({
      _focusKey: settings.focusMinutes,
      _shortKey: settings.shortBreakMinutes,
      _longKey: settings.longBreakMinutes,
    });
  }

  @override
  Future<bool> isOnboardingDone() async =>
      (_box.get(_onboardingKey) as bool?) ?? false;

  @override
  Future<void> setOnboardingDone() => _box.put(_onboardingKey, true);

  @override
  Future<String?> loadLanguageCode() async => _box.get(_languageKey) as String?;

  @override
  Future<void> saveLanguageCode(String code) async {
    if (!_supportedLanguages.contains(code)) {
      throw const ValidationException(AppError.unknown);
    }
    await _box.put(_languageKey, code);
  }
}
