import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../domain/entities/focus_task.dart';

Future<bool> confirmDeleteTask(BuildContext context, FocusTask task) async {
  final s = AppStrings.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(s.deleteTaskTitle),
      content: Text(s.deleteTaskMessage(task.title)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(s.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(s.delete),
        ),
      ],
    ),
  );
  return result ?? false;
}
