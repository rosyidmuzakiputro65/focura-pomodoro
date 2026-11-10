import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../domain/entities/focus_task.dart';

enum TaskMenuAction { edit, focus, delete }

String priorityLabel(AppStrings s, TaskPriority priority) => switch (priority) {
  TaskPriority.low => s.priorityLow,
  TaskPriority.medium => s.priorityMedium,
  TaskPriority.high => s.priorityHigh,
};

Color priorityColor(TaskPriority priority) => switch (priority) {
  TaskPriority.low => AppColors.shortBreak,
  TaskPriority.medium => AppColors.longBreak,
  TaskPriority.high => AppColors.primary,
};

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.isActive,
    required this.onToggle,
    required this.onTap,
    required this.onMenu,
  });

  final FocusTask task;
  final bool isActive;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final ValueChanged<TaskMenuAction> onMenu;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final color = priorityColor(task.priority);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive ? AppColors.primary : AppColors.border,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: task.isDone,
                onChanged: (_) => onToggle(),
                activeColor: AppColors.shortBreak,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: task.isDone
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _Chip(
                            label: priorityLabel(s, task.priority),
                            color: color,
                          ),
                          _Chip(
                            label: s.pomodoroCount(
                              task.completedPomodoros,
                              task.estimatedPomodoros,
                            ),
                            color: AppColors.textSecondary,
                            icon: Icons.timer_outlined,
                          ),
                          if (isActive)
                            _Chip(
                              label: s.focusing,
                              color: AppColors.primary,
                              icon: Icons.play_circle_outline_rounded,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: task.progress,
                          minHeight: 4,
                          color: task.isDone ? AppColors.shortBreak : color,
                          backgroundColor: AppColors.border,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PopupMenuButton<TaskMenuAction>(
                tooltip: s.taskOptions,
                onSelected: onMenu,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: TaskMenuAction.edit,
                    child: ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(s.edit),
                    ),
                  ),
                  if (!task.isDone)
                    PopupMenuItem(
                      value: TaskMenuAction.focus,
                      child: ListTile(
                        leading: const Icon(Icons.play_arrow_rounded),
                        title: Text(s.focusThisTask),
                      ),
                    ),
                  PopupMenuItem(
                    value: TaskMenuAction.delete,
                    child: ListTile(
                      leading: const Icon(Icons.delete_outline_rounded),
                      title: Text(s.delete),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
