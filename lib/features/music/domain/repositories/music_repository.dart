import '../entities/focus_track.dart';

abstract class MusicRepository {
  Future<MusicPreferences> load();

  Future<void> save(MusicPreferences preferences);
}
