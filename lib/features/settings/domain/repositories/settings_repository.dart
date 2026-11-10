import '../entities/timer_settings.dart';

abstract class SettingsRepository {
  Future<TimerSettings> loadTimerSettings();

  Future<void> saveTimerSettings(TimerSettings settings);

  Future<bool> isOnboardingDone();

  Future<void> setOnboardingDone();

  /// Kode bahasa yang dipilih pengguna (`id` / `en`), atau `null` jika
  /// belum pernah memilih (ikut bahasa perangkat).
  Future<String?> loadLanguageCode();

  Future<void> saveLanguageCode(String code);
}
