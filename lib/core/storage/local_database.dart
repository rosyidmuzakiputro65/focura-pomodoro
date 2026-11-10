import 'package:hive_ce_flutter/hive_flutter.dart';

/// Database lokal aplikasi berbasis Hive.
///
/// Hive berjalan di Android, iOS, Web (IndexedDB) dan Desktop sehingga
/// aplikasi tetap bisa dicoba lewat `flutter run -d chrome`.
class LocalDatabase {
  const LocalDatabase._();

  static const String usersBox = 'users';
  static const String sessionBox = 'session';
  static const String tasksBox = 'tasks';
  static const String focusSessionsBox = 'focus_sessions';
  static const String settingsBox = 'settings';
  static const String quotesCacheBox = 'quotes_cache';
  static const String translationsCacheBox = 'translations_cache';

  static const List<String> allBoxes = [
    usersBox,
    sessionBox,
    tasksBox,
    focusSessionsBox,
    settingsBox,
    quotesCacheBox,
    translationsCacheBox,
  ];

  static Future<void> init() async {
    await Hive.initFlutter('focura');
    for (final name in allBoxes) {
      await Hive.openBox<dynamic>(name);
    }
  }

  static Box<dynamic> box(String name) => Hive.box<dynamic>(name);
}
