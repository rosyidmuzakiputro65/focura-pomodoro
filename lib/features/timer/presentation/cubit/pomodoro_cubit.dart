import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/notification_service.dart';

enum PomodoroMode { focus, shortBreak, longBreak }

/// Teks notifikasi saat sesi berakhir. Diisi dari `AppStrings` sesuai
/// bahasa yang dipilih, sehingga Cubit sendiri tidak berisi teks UI.
class SessionNotificationCopy extends Equatable {
  const SessionNotificationCopy({
    required this.focusDoneTitle,
    required this.focusDoneBody,
    required this.breakDoneTitle,
    required this.breakDoneBody,
  });

  final String focusDoneTitle;
  final String focusDoneBody;
  final String breakDoneTitle;
  final String breakDoneBody;

  @override
  List<Object?> get props => [
    focusDoneTitle,
    focusDoneBody,
    breakDoneTitle,
    breakDoneBody,
  ];
}

class PomodoroState extends Equatable {
  const PomodoroState({
    required this.mode,
    required this.durationSeconds,
    required this.remainingSeconds,
    required this.completedFocusSessions,
    required this.isRunning,
    this.finishedCount = 0,
    this.lastFinishedMode,
    this.lastFinishedSeconds = 0,
  });

  factory PomodoroState.initial(int focusSeconds) {
    return PomodoroState(
      mode: PomodoroMode.focus,
      durationSeconds: focusSeconds,
      remainingSeconds: focusSeconds,
      completedFocusSessions: 0,
      isRunning: false,
    );
  }

  final PomodoroMode mode;
  final int durationSeconds;
  final int remainingSeconds;
  final int completedFocusSessions;
  final bool isRunning;

  /// Bertambah setiap kali sebuah sesi (fokus/istirahat) selesai.
  /// UI mendengarkan perubahan ini untuk menampilkan informasi sesi selesai.
  final int finishedCount;
  final PomodoroMode? lastFinishedMode;
  final int lastFinishedSeconds;

  double get progress =>
      durationSeconds == 0 ? 0 : remainingSeconds / durationSeconds;

  bool get isPristine => !isRunning && remainingSeconds == durationSeconds;

  int get sessionsInCurrentCycle =>
      completedFocusSessions == 0 ? 0 : ((completedFocusSessions - 1) % 4) + 1;

  String get timeText {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  PomodoroState copyWith({
    PomodoroMode? mode,
    int? durationSeconds,
    int? remainingSeconds,
    int? completedFocusSessions,
    bool? isRunning,
    int? finishedCount,
    PomodoroMode? lastFinishedMode,
    int? lastFinishedSeconds,
  }) {
    return PomodoroState(
      mode: mode ?? this.mode,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      completedFocusSessions:
          completedFocusSessions ?? this.completedFocusSessions,
      isRunning: isRunning ?? this.isRunning,
      finishedCount: finishedCount ?? this.finishedCount,
      lastFinishedMode: lastFinishedMode ?? this.lastFinishedMode,
      lastFinishedSeconds: lastFinishedSeconds ?? this.lastFinishedSeconds,
    );
  }

  @override
  List<Object?> get props => [
    mode,
    durationSeconds,
    remainingSeconds,
    completedFocusSessions,
    isRunning,
    finishedCount,
    lastFinishedMode,
    lastFinishedSeconds,
  ];
}

/// Seluruh logika timer Pomodoro. Tidak ada widget di sini.
class PomodoroCubit extends Cubit<PomodoroState> {
  PomodoroCubit({
    Duration focusDuration = const Duration(minutes: 25),
    Duration shortBreakDuration = const Duration(minutes: 5),
    Duration longBreakDuration = const Duration(minutes: 15),
    Duration tickInterval = const Duration(seconds: 1),
    DateTime Function()? now,
    this._notifications = const NoopNotificationService(),
    SessionNotificationCopy? notificationCopy,
  }) : _copy = notificationCopy,
       _durations = {
         PomodoroMode.focus: focusDuration,
         PomodoroMode.shortBreak: shortBreakDuration,
         PomodoroMode.longBreak: longBreakDuration,
       },
       _tickInterval = tickInterval,
       _now = now ?? DateTime.now,
       super(PomodoroState.initial(focusDuration.inSeconds)) {
    _assertDurations(_durations);
    if (tickInterval <= Duration.zero) {
      throw ArgumentError('The timer tick interval must be greater than zero.');
    }
  }

  final Map<PomodoroMode, Duration> _durations;
  final Duration _tickInterval;
  final DateTime Function() _now;
  final NotificationService _notifications;
  SessionNotificationCopy? _copy;
  Timer? _ticker;
  DateTime? _endsAt;

  /// Mengganti bahasa teks notifikasi (dipanggil saat bahasa diganti).
  void setNotificationCopy(SessionNotificationCopy copy) => _copy = copy;

  Duration durationOf(PomodoroMode mode) => _durations[mode]!;

  /// Mengganti durasi dari halaman pengaturan. Jika timer belum berjalan,
  /// tampilan langsung diperbarui; jika sedang berjalan, durasi baru
  /// dipakai mulai sesi berikutnya.
  void updateDurations({
    required Duration focus,
    required Duration shortBreak,
    required Duration longBreak,
  }) {
    final next = {
      PomodoroMode.focus: focus,
      PomodoroMode.shortBreak: shortBreak,
      PomodoroMode.longBreak: longBreak,
    };
    _assertDurations(next);
    _durations
      ..clear()
      ..addAll(next);
    if (state.isPristine) {
      final seconds = next[state.mode]!.inSeconds;
      emit(state.copyWith(durationSeconds: seconds, remainingSeconds: seconds));
    }
  }

  void selectMode(PomodoroMode mode) {
    _stopTicker();
    final durationSeconds = _durations[mode]!.inSeconds;
    emit(
      state.copyWith(
        mode: mode,
        durationSeconds: durationSeconds,
        remainingSeconds: durationSeconds,
        isRunning: false,
      ),
    );
  }

  void start() {
    if (state.isRunning) return;

    final endsAt = _now().add(Duration(seconds: state.remainingSeconds));
    _endsAt = endsAt;
    emit(state.copyWith(isRunning: true));
    _ticker = Timer.periodic(_tickInterval, (_) => _tick());
    final copy = _copy;
    if (copy != null) {
      final isFocus = state.mode == PomodoroMode.focus;
      unawaited(
        _notifications.scheduleSessionEnd(
          at: endsAt,
          title: isFocus ? copy.focusDoneTitle : copy.breakDoneTitle,
          body: isFocus ? copy.focusDoneBody : copy.breakDoneBody,
        ),
      );
    }
  }

  void pause() {
    if (!state.isRunning || _endsAt == null) return;

    final remainingSeconds = _secondsUntil(_endsAt!);
    if (remainingSeconds == 0) {
      _finishSession();
      return;
    }

    _stopTicker();
    emit(state.copyWith(remainingSeconds: remainingSeconds, isRunning: false));
  }

  void toggle() {
    if (state.isRunning) {
      pause();
    } else {
      start();
    }
  }

  void reset() {
    _stopTicker();
    emit(
      state.copyWith(remainingSeconds: state.durationSeconds, isRunning: false),
    );
  }

  /// Mengembalikan timer ke kondisi awal (dipakai saat logout).
  void resetAll() {
    _stopTicker();
    emit(PomodoroState.initial(_durations[PomodoroMode.focus]!.inSeconds));
  }

  void skip() {
    _stopTicker();
    final nextMode = state.mode == PomodoroMode.focus
        ? PomodoroMode.shortBreak
        : PomodoroMode.focus;
    _emitMode(nextMode);
  }

  void _tick() {
    final endsAt = _endsAt;
    if (endsAt == null || !state.isRunning) return;

    final remainingSeconds = _secondsUntil(endsAt);
    if (remainingSeconds == 0) {
      _finishSession();
    } else if (remainingSeconds != state.remainingSeconds) {
      emit(state.copyWith(remainingSeconds: remainingSeconds));
    }
  }

  int _secondsUntil(DateTime deadline) {
    final milliseconds = deadline.difference(_now()).inMilliseconds;
    if (milliseconds <= 0) return 0;
    return (milliseconds / 1000).ceil();
  }

  void _finishSession() {
    // Notifikasi terjadwal sudah/akan muncul sendiri, jadi ticker saja
    // yang dihentikan (tanpa membatalkan notifikasi).
    _ticker?.cancel();
    _ticker = null;
    _endsAt = null;

    final finishedMode = state.mode;
    final finishedSeconds = state.durationSeconds;

    if (finishedMode == PomodoroMode.focus) {
      final completedSessions = state.completedFocusSessions + 1;
      final nextMode = completedSessions % 4 == 0
          ? PomodoroMode.longBreak
          : PomodoroMode.shortBreak;
      _emitMode(
        nextMode,
        completedFocusSessions: completedSessions,
        finishedMode: finishedMode,
        finishedSeconds: finishedSeconds,
      );
    } else {
      _emitMode(
        PomodoroMode.focus,
        finishedMode: finishedMode,
        finishedSeconds: finishedSeconds,
      );
    }
  }

  void _emitMode(
    PomodoroMode mode, {
    int? completedFocusSessions,
    PomodoroMode? finishedMode,
    int? finishedSeconds,
  }) {
    final durationSeconds = _durations[mode]!.inSeconds;
    emit(
      state.copyWith(
        mode: mode,
        durationSeconds: durationSeconds,
        remainingSeconds: durationSeconds,
        completedFocusSessions: completedFocusSessions,
        isRunning: false,
        finishedCount: finishedMode == null ? null : state.finishedCount + 1,
        lastFinishedMode: finishedMode,
        lastFinishedSeconds: finishedSeconds,
      ),
    );
  }

  void _stopTicker() {
    final wasScheduled = _ticker != null;
    _ticker?.cancel();
    _ticker = null;
    _endsAt = null;
    if (wasScheduled) unawaited(_notifications.cancelSessionEnd());
  }

  static void _assertDurations(Map<PomodoroMode, Duration> durations) {
    if (durations.values.any((duration) => duration.inSeconds < 1)) {
      throw ArgumentError('Pomodoro durations must be at least one second.');
    }
  }

  @override
  Future<void> close() {
    _stopTicker();
    return super.close();
  }
}
