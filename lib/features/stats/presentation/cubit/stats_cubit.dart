import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/focus_session_record.dart';
import '../../domain/repositories/session_repository.dart';

class StatsState extends Equatable {
  const StatsState({
    this.userId,
    this.todaySessions = 0,
    this.todayMinutes = 0,
    this.totalSessions = 0,
    this.totalMinutes = 0,
    this.lastSevenDays = const [],
  });

  final String? userId;
  final int todaySessions;
  final int todayMinutes;
  final int totalSessions;
  final int totalMinutes;
  final List<DailyFocus> lastSevenDays;

  @override
  List<Object?> get props => [
    userId,
    todaySessions,
    todayMinutes,
    totalSessions,
    totalMinutes,
    lastSevenDays,
  ];
}

class StatsCubit extends Cubit<StatsState> {
  StatsCubit(this._repository, {DateTime Function()? now})
    : _now = now ?? DateTime.now,
      super(const StatsState());

  final SessionRepository _repository;
  final DateTime Function() _now;

  Future<void> setUser(String? userId) async {
    if (userId == null) {
      emit(const StatsState());
      return;
    }
    emit(StatsState(userId: userId));
    await refresh();
  }

  Future<void> recordFocusSession({required int minutes, String? taskTitle}) async {
    final userId = state.userId;
    if (userId == null) return;
    try {
      await _repository.addSession(
        userId: userId,
        minutes: minutes,
        taskTitle: taskTitle,
      );
    } on AppException {
      return;
    }
    await refresh();
  }

  Future<void> refresh() async {
    final userId = state.userId;
    if (userId == null) return;
    final List<FocusSessionRecord> sessions;
    try {
      sessions = await _repository.getSessions(userId);
    } on AppException {
      return; // tetap tampilkan statistik terakhir
    }
    final today = AppDateUtils.startOfDay(_now());

    final todaySessions = sessions
        .where((s) => AppDateUtils.isSameDay(s.completedAt, today))
        .toList();

    final days = List.generate(7, (index) {
      final day = today.subtract(Duration(days: 6 - index));
      final minutes = sessions
          .where((s) => AppDateUtils.isSameDay(s.completedAt, day))
          .fold<int>(0, (sum, s) => sum + s.minutes);
      return DailyFocus(day: day, minutes: minutes);
    });

    emit(
      StatsState(
        userId: userId,
        todaySessions: todaySessions.length,
        todayMinutes: todaySessions.fold<int>(0, (sum, s) => sum + s.minutes),
        totalSessions: sessions.length,
        totalMinutes: sessions.fold<int>(0, (sum, s) => sum + s.minutes),
        lastSevenDays: days,
      ),
    );
  }
}
