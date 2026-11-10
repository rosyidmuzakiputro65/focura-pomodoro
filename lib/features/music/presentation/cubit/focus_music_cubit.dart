import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/focus_audio_service.dart';
import '../../domain/entities/focus_track.dart';
import '../../domain/repositories/music_repository.dart';

class FocusMusicState extends Equatable {
  const FocusMusicState({
    this.track = FocusTrack.piano,
    this.volume = 0.6,
    this.playDuringBreaks = false,
    this.isPlaying = false,
  });

  final FocusTrack track;
  final double volume;
  final bool playDuringBreaks;
  final bool isPlaying;

  bool get isOff => track == FocusTrack.none;

  FocusMusicState copyWith({
    FocusTrack? track,
    double? volume,
    bool? playDuringBreaks,
    bool? isPlaying,
  }) {
    return FocusMusicState(
      track: track ?? this.track,
      volume: volume ?? this.volume,
      playDuringBreaks: playDuringBreaks ?? this.playDuringBreaks,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  List<Object?> get props => [track, volume, playDuringBreaks, isPlaying];
}

/// Mengatur musik penenang:
/// - otomatis diputar saat sesi fokus dimulai,
/// - dijeda saat timer dijeda / sesi selesai / waktu istirahat
///   (kecuali "putar juga saat istirahat" aktif),
/// - bisa didengarkan manual dari kartu musik.
class FocusMusicCubit extends Cubit<FocusMusicState> {
  FocusMusicCubit({required this._audio, required this._repository})
    : super(const FocusMusicState());

  final FocusAudioService _audio;
  final MusicRepository _repository;

  bool _timerRunning = false;
  bool _isFocusMode = true;

  Future<void> load() async {
    final prefs = await _repository.load();
    emit(
      state.copyWith(
        track: prefs.track,
        volume: prefs.volume,
        playDuringBreaks: prefs.playDuringBreaks,
      ),
    );
  }

  /// Dipanggil setiap kali status timer berubah.
  Future<void> onTimerChanged({
    required bool isRunning,
    required bool isFocusMode,
  }) async {
    _timerRunning = isRunning;
    _isFocusMode = isFocusMode;
    if (_shouldAutoPlay) {
      await _play();
    } else if (state.isPlaying) {
      await _pause();
    }
  }

  bool get _shouldAutoPlay =>
      _timerRunning && !state.isOff && (_isFocusMode || state.playDuringBreaks);

  /// Tombol putar/jeda di kartu musik.
  Future<void> togglePlay() async {
    if (state.isPlaying) {
      await _pause();
    } else if (!state.isOff) {
      await _play();
    }
  }

  Future<void> selectTrack(FocusTrack track) async {
    if (track == state.track) return;
    final wasPlaying = state.isPlaying;
    await _audio.stop();
    emit(state.copyWith(track: track, isPlaying: false));
    await _save();
    if (track != FocusTrack.none && (wasPlaying || _shouldAutoPlay)) {
      await _play();
    }
  }

  Future<void> setVolume(double volume) async {
    final value = volume.clamp(0.0, 1.0).toDouble();
    emit(state.copyWith(volume: value));
    await _audio.setVolume(value);
  }

  /// Simpan volume setelah slider dilepas (supaya tidak menulis terus-menerus).
  Future<void> saveVolume() => _save();

  Future<void> setPlayDuringBreaks(bool value) async {
    emit(state.copyWith(playDuringBreaks: value));
    await _save();
    await onTimerChanged(isRunning: _timerRunning, isFocusMode: _isFocusMode);
  }

  /// Menghentikan musik sepenuhnya (dipakai saat logout).
  Future<void> stopAll() async {
    _timerRunning = false;
    await _audio.stop();
    emit(state.copyWith(isPlaying: false));
  }

  Future<void> _play() async {
    final asset = state.track.assetPath;
    if (asset == null) return;
    emit(state.copyWith(isPlaying: true));
    await _audio.play(asset, volume: state.volume);
  }

  Future<void> _pause() async {
    emit(state.copyWith(isPlaying: false));
    await _audio.pause();
  }

  Future<void> _save() => _repository.save(
    MusicPreferences(
      track: state.track,
      volume: state.volume,
      playDuringBreaks: state.playDuringBreaks,
    ),
  );

  @override
  Future<void> close() async {
    await _audio.dispose();
    return super.close();
  }
}
