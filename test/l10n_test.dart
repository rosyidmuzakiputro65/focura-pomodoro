import 'package:flutter_application_1/core/errors/app_exception.dart';
import 'package:flutter_application_1/core/l10n/app_strings.dart';
import 'package:flutter_application_1/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';

void main() {
  group('AppStrings', () {
    const id = AppStringsId();
    const en = AppStringsEn();

    test('memilih bahasa dari kode', () {
      expect(AppStrings.forLanguageCode('en'), isA<AppStringsEn>());
      expect(AppStrings.forLanguageCode('id'), isA<AppStringsId>());
      expect(AppStrings.forLanguageCode('fr'), isA<AppStringsId>());
    });

    test('setiap kode error punya pesan di kedua bahasa', () {
      for (final error in AppError.values) {
        expect(id.error(error), isNotEmpty, reason: error.name);
        expect(en.error(error), isNotEmpty, reason: error.name);
        expect(id.error(error), isNot(en.error(error)), reason: error.name);
      }
    });

    test('teks dengan parameter', () {
      expect(id.completedOf(2, 5), '2 dari 5 selesai');
      expect(en.completedOf(2, 5), '2 of 5 done');
      expect(en.sessionsCompleted(1), '1 session completed');
      expect(en.sessionsCompleted(3), '3 sessions completed');
      expect(id.shortDayNames.length, 7);
      expect(en.shortDayNames.first, 'Mon');
    });
  });

  group('SettingsCubit bahasa', () {
    test('mengikuti bahasa perangkat jika belum memilih', () async {
      final cubit = SettingsCubit(
        InMemorySettingsRepository(),
        systemLanguageCode: 'en',
      );
      await cubit.load();
      expect(cubit.state.languageCode, 'en');
      await cubit.close();
    });

    test('bahasa perangkat tidak didukung -> Indonesia', () async {
      final cubit = SettingsCubit(
        InMemorySettingsRepository(),
        systemLanguageCode: 'ja',
      );
      expect(cubit.state.languageCode, 'id');
      await cubit.close();
    });

    test('pilihan pengguna disimpan dan dipakai lagi', () async {
      final repo = InMemorySettingsRepository();
      final first = SettingsCubit(repo);
      await first.changeLanguage('en');
      expect(first.state.languageCode, 'en');
      expect(repo.languageCode, 'en');
      await first.close();

      final second = SettingsCubit(repo, systemLanguageCode: 'id');
      await second.load();
      expect(second.state.languageCode, 'en');
      await second.close();
    });
  });
}
