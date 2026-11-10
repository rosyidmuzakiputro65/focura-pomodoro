import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../domain/entities/focus_task.dart';
import '../cubit/task_cubit.dart';
import '../widgets/delete_task_dialog.dart';
import '../widgets/task_tile.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key, this.onStartFocus});

  /// Dipanggil saat pengguna memilih "Fokuskan tugas ini" agar
  /// HomeShell berpindah ke tab Timer.
  final VoidCallback? onStartFocus;

  Future<void> _openForm(BuildContext context, [FocusTask? task]) {
    return Navigator.of(context).pushNamed(AppRoutes.taskForm, arguments: task);
  }

  Future<void> _handleMenu(
    BuildContext context,
    FocusTask task,
    TaskMenuAction action,
  ) async {
    final cubit = context.read<TaskCubit>();
    switch (action) {
      case TaskMenuAction.edit:
        await _openForm(context, task);
      case TaskMenuAction.focus:
        cubit.setActiveTask(task.id);
        onStartFocus?.call();
      case TaskMenuAction.delete:
        if (await confirmDeleteTask(context, task)) {
          await cubit.deleteTask(task);
        }
    }
  }

  static String _filterLabel(AppStrings s, TaskFilter filter) =>
      switch (filter) {
        TaskFilter.all => s.filterAll,
        TaskFilter.pending => s.filterPending,
        TaskFilter.completed => s.filterCompleted,
      };

  static String _feedbackText(AppStrings s, TaskFeedback feedback) =>
      switch (feedback) {
        TaskFeedback.added => s.taskAdded,
        TaskFeedback.updated => s.taskUpdated,
        TaskFeedback.deleted => s.taskDeleted,
      };

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.tasksTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_task',
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(s.add),
      ),
      body: BlocConsumer<TaskCubit, TaskState>(
        listenWhen: (p, c) =>
            c.hasMessage && (p.feedback != c.feedback || p.error != c.error),
        listener: (context, state) {
          final text = state.error != null
              ? s.error(state.error!)
              : _feedbackText(s, state.feedback!);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(text)));
          context.read<TaskCubit>().clearMessage();
        },
        builder: (context, state) {
          final cubit = context.read<TaskCubit>();
          final tasks = state.visibleTasks;
          return ResponsiveCenter(
            maxWidth: 720,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<TaskFilter>(
                      showSelectedIcon: false,
                      segments: [
                        for (final filter in TaskFilter.values)
                          ButtonSegment(
                            value: filter,
                            label: Text(_filterLabel(s, filter)),
                          ),
                      ],
                      selected: {state.filter},
                      onSelectionChanged: (value) => cubit.setFilter(value.first),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        s.completedOf(state.completedCount, state.tasks.length),
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: switch (state.status) {
                    TaskStatus.loading || TaskStatus.initial => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    _ when tasks.isEmpty => EmptyState(
                      icon: Icons.inbox_outlined,
                      title: state.tasks.isEmpty ? s.noTasks : s.noTasksInFilter,
                      message: s.emptyTasksMessage,
                      action: state.tasks.isEmpty
                          ? FilledButton.icon(
                              onPressed: () => _openForm(context),
                              icon: const Icon(Icons.add_rounded),
                              label: Text(s.createFirstTask),
                            )
                          : null,
                    ),
                    _ => RefreshIndicator(
                      onRefresh: cubit.load,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                        itemCount: tasks.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Dismissible(
                            key: ValueKey(task.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) => confirmDeleteTask(context, task),
                            onDismissed: (_) => cubit.deleteTask(task),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                            child: TaskTile(
                              task: task,
                              isActive: task.id == state.activeTaskId,
                              onToggle: () => cubit.toggleDone(task),
                              onTap: () => _openForm(context, task),
                              onMenu: (action) =>
                                  _handleMenu(context, task, action),
                            ),
                          );
                        },
                      ),
                    ),
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
