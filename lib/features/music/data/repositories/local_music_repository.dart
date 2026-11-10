import 'package:hive_ce/hive.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/focus_track.dart';
import '../../domain/repositories/music_repository.dart';

class LocalMusicRepository implements MusicRepository {
  LocalMusicRepository(this._box);

  final Box<dynamic> _box;

  static const String _trackKey = 'musicTrack';
  static const String _volumeKey = 'musicVolume';
  static const String _breaksKey = 'musicDuringBreaks';

  @override
  Future<MusicPreferences> load() async {
    const defaults = MusicPreferences();
    return MusicPreferences(
      track: FocusTrack.fromName(_box.get(_trackKey) as String?),
      volume: (_box.get(_volumeKey) as num?)?.toDouble() ?? defaults.volume,
      playDuringBreaks: (_box.get(_breaksKey) as bool?) ?? false,
    );
  }

  @override
  Future<void> save(MusicPreferences preferences) async {
    if (preferences.volume < 0 || preferences.volume > 1) {
      throw const ValidationException(AppError.unknown);
    }
    await _box.putAll({
      _trackKey: preferences.track.name,
      _volumeKey: preferences.volume,
      _breaksKey: preferences.playDuringBreaks,
    });
  }
}
