import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../cubit/pomodoro_cubit.dart';

Color modeColor(PomodoroMode mode) => switch (mode) {
  PomodoroMode.focus => AppColors.primary,
  PomodoroMode.shortBreak => AppColors.shortBreak,
  PomodoroMode.longBreak => AppColors.longBreak,
};

/// Nama mode lengkap, contoh: "Istirahat pendek" / "Short break".
String modeLabel(AppStrings s, PomodoroMode mode) => switch (mode) {
  PomodoroMode.focus => s.modeFocus,
  PomodoroMode.shortBreak => s.modeShortBreak,
  PomodoroMode.longBreak => s.modeLongBreak,
};

/// Nama mode singkat untuk tombol segmen.
String modeShortLabel(AppStrings s, PomodoroMode mode) => switch (mode) {
  PomodoroMode.focus => s.modeFocusShort,
  PomodoroMode.shortBreak => s.modeShortBreakShort,
  PomodoroMode.longBreak => s.modeLongBreakShort,
};

String modeTitle(AppStrings s, PomodoroMode mode) => switch (mode) {
  PomodoroMode.focus => s.modeFocusTitle,
  PomodoroMode.shortBreak => s.modeShortBreakTitle,
  PomodoroMode.longBreak => s.modeLongBreakTitle,
};

String modeDescription(AppStrings s, PomodoroMode mode) => switch (mode) {
  PomodoroMode.focus => s.modeFocusDescription,
  PomodoroMode.shortBreak => s.modeShortBreakDescription,
  PomodoroMode.longBreak => s.modeLongBreakDescription,
};
