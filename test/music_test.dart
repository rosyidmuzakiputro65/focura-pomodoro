import 'package:flutter_application_1/core/services/focus_audio_service.dart';
import 'package:flutter_application_1/features/music/domain/entities/focus_track.dart';
import 'package:flutter_application_1/features/music/presentation/cubit/focus_music_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';

void main() {
  late SilentFocusAudioService audio;
  late InMemoryMusicRepository repo;
  late FocusMusicCubit cubit;

  setUp(() async {
    audio = SilentFocusAudioService();
    repo = InMemoryMusicRepository();
    cubit = FocusMusicCubit(audio: audio, repository: repo);
    await cubit.load();
  });

  tearDown(() => cubit.close());

  test('semua trek punya file aset kecuali "mati"', () {
    for (final track in FocusTrack.values) {
      expect(track.assetPath == null, track == FocusTrack.none);
    }
  });

  test('musik diputar saat fokus dimulai dan dijeda saat timer dijeda', () async {
    await cubit.onTimerChanged(isRunning: true, isFocusMode: true);
    expect(cubit.state.isPlaying, isTrue);
    expect(audio.log.last, 'play:audio/piano_tenang.mp3');

    await cubit.onTimerChanged(isRunning: false, isFocusMode: true);
    expect(cubit.state.isPlaying, isFalse);
    expect(audio.log.last, 'pause');
  });

  test('saat istirahat musik berhenti, kecuali opsi istirahat aktif', () async {
    await cubit.onTimerChanged(isRunning: true, isFocusMode: false);
    expect(cubit.state.isPlaying, isFalse);

    await cubit.setPlayDuringBreaks(true);
    expect(cubit.state.isPlaying, isTrue);
    expect(repo.saved.playDuringBreaks, isTrue);
  });

  test('mode "mati" tidak memutar apa pun', () async {
    await cubit.selectTrack(FocusTrack.none);
    await cubit.onTimerChanged(isRunning: true, isFocusMode: true);
    expect(cubit.state.isPlaying, isFalse);
    expect(audio.log.where((e) => e.startsWith('play')), isEmpty);
    expect(repo.saved.track, FocusTrack.none);
  });

  test('ganti trek saat sedang diputar langsung memutar trek baru', () async {
    await cubit.togglePlay();
    await cubit.selectTrack(FocusTrack.rain);
    expect(cubit.state.isPlaying, isTrue);
    expect(audio.log.last, 'play:audio/hujan_lembut.mp3');
  });

  test('volume dibatasi 0..1 dan disimpan', () async {
    await cubit.setVolume(1.7);
    expect(cubit.state.volume, 1.0);
    await cubit.saveVolume();
    expect(repo.saved.volume, 1.0);
  });

  test('stopAll saat logout', () async {
    await cubit.onTimerChanged(isRunning: true, isFocusMode: true);
    await cubit.stopAll();
    expect(cubit.state.isPlaying, isFalse);
    expect(audio.log.last, 'stop');
  });
}
