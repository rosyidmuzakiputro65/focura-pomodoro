/// Musik penenang yang tersedia. Semua trek dibuat khusus untuk Focura
/// (lihat `tool/generate_focus_music.py`) sehingga bebas hak cipta.
enum FocusTrack {
  none(null),
  piano('audio/piano_tenang.mp3'),
  ambient('audio/ambient_senja.mp3'),
  rain('audio/hujan_lembut.mp3'),
  ocean('audio/ombak_pantai.mp3'),
  brownNoise('audio/brown_noise.mp3');

  const FocusTrack(this.assetPath);

  /// Path relatif terhadap folder `assets/`, `null` untuk "mati".
  final String? assetPath;

  static FocusTrack fromName(String? name) => FocusTrack.values.firstWhere(
    (track) => track.name == name,
    orElse: () => FocusTrack.piano,
  );
}

class MusicPreferences {
  const MusicPreferences({
    this.track = FocusTrack.piano,
    this.volume = 0.6,
    this.playDuringBreaks = false,
  });

  final FocusTrack track;
  final double volume;
  final bool playDuringBreaks;
}
