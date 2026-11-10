import 'package:equatable/equatable.dart';

class TimerSettings extends Equatable {
  const TimerSettings({
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
  });

  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;

  Duration get focus => Duration(minutes: focusMinutes);
  Duration get shortBreak => Duration(minutes: shortBreakMinutes);
  Duration get longBreak => Duration(minutes: longBreakMinutes);

  TimerSettings copyWith({
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
  }) {
    return TimerSettings(
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
    );
  }

  @override
  List<Object?> get props => [focusMinutes, shortBreakMinutes, longBreakMinutes];
}
