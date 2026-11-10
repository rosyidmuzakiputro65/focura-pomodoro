import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Kontrak pemutar musik fokus. Cubit hanya bergantung pada kelas ini,
/// sehingga mudah diuji tanpa memutar suara sungguhan.
abstract class FocusAudioService {
  /// Memutar aset (contoh `audio/piano_tenang.mp3`) secara berulang.
  Future<void> play(String assetPath, {required double volume});

  Future<void> pause();

  Future<void> setVolume(double volume);

  Future<void> stop();

  Future<void> dispose();
}

/// Implementasi dengan package `audioplayers` (Android, iOS, Web, desktop).
class AudioplayersFocusAudioService implements FocusAudioService {
  AudioplayersFocusAudioService([AudioPlayer? player])
    : _player = player ?? AudioPlayer(playerId: 'focura_focus_music');

  final AudioPlayer _player;
  String? _currentAsset;

  @override
  Future<void> play(String assetPath, {required double volume}) async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(volume);
      if (_currentAsset == assetPath &&
          _player.state == PlayerState.paused) {
        await _player.resume();
        return;
      }
      _currentAsset = assetPath;
      await _player.play(AssetSource(assetPath), volume: volume);
    } catch (error) {
      debugPrint('Gagal memutar musik: $error');
    }
  }

  @override
  Future<void> pause() async {
    try {
      if (_player.state == PlayerState.playing) await _player.pause();
    } catch (error) {
      debugPrint('Gagal menjeda musik: $error');
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume);
    } catch (error) {
      debugPrint('Gagal mengatur volume: $error');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
      _currentAsset = null;
    } catch (error) {
      debugPrint('Gagal menghentikan musik: $error');
    }
  }

  @override
  Future<void> dispose() => _player.dispose();
}

/// Versi tanpa suara untuk pengujian.
class SilentFocusAudioService implements FocusAudioService {
  final List<String> log = [];

  @override
  Future<void> play(String assetPath, {required double volume}) async =>
      log.add('play:$assetPath');

  @override
  Future<void> pause() async => log.add('pause');

  @override
  Future<void> setVolume(double volume) async => log.add('volume:$volume');

  @override
  Future<void> stop() async => log.add('stop');

  @override
  Future<void> dispose() async {}
}
