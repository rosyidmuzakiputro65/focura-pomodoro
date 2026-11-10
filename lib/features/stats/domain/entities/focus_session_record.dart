import 'package:equatable/equatable.dart';

/// Riwayat satu sesi fokus yang selesai.
class FocusSessionRecord extends Equatable {
  const FocusSessionRecord({
    required this.id,
    required this.userId,
    required this.minutes,
    required this.completedAt,
    this.taskTitle,
  });

  final String id;
  final String userId;
  final int minutes;
  final DateTime completedAt;
  final String? taskTitle;

  @override
  List<Object?> get props => [id, userId, minutes, completedAt, taskTitle];
}

class DailyFocus extends Equatable {
  const DailyFocus({required this.day, required this.minutes});

  final DateTime day;
  final int minutes;

  @override
  List<Object?> get props => [day, minutes];
}
