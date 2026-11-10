import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../cubit/pomodoro_cubit.dart';
import 'timer_style.dart';

/// Informasi yang ditampilkan ketika sebuah sesi selesai
/// (fitur nomor 3 pada proposal).
Future<void> showSessionCompleteDialog(
  BuildContext context, {
  required PomodoroMode finishedMode,
  required PomodoroMode nextMode,
  required int completedFocusSessions,
  required VoidCallback onStartNext,
}) {
  final s = AppStrings.of(context);
  final wasFocus = finishedMode == PomodoroMode.focus;
  final color = modeColor(nextMode);
  final nextLabel = modeLabel(s, nextMode);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.cardBg,
      icon: Icon(
        wasFocus ? Icons.celebration_rounded : Icons.bolt_rounded,
        color: color,
        size: 40,
      ),
      title: Text(wasFocus ? s.focusDoneTitle : s.breakDoneTitle),
      content: Text(
        wasFocus
            ? s.focusDoneBody(completedFocusSessions, nextLabel)
            : s.breakDoneBody,
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.later),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: AppColors.background,
          ),
          onPressed: () {
            Navigator.pop(context);
            onStartNext();
          },
          child: Text(s.startMode(nextLabel)),
        ),
      ],
    ),
  );
}
