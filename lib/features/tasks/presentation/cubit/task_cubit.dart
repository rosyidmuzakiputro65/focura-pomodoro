import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/focus_task.dart';
import '../../domain/repositories/task_repository.dart';

part 'task_state.dart';

/// Business logic untuk Create, Read, Update, Delete tugas.
class TaskCubit extends Cubit<TaskState> {
  TaskCubit(this._repository) : super(const TaskState());

  final TaskRepository _repository;

  /// Dipanggil saat pengguna login/logout.
  Future<void> setUser(String? userId) async {
    if (userId == null) {
      emit(const TaskState());
      return;
    }
    emit(TaskState(userId: userId));
    await load();
  }

  Future<void> load() async {
    final userId = state.userId;
    if (userId == null) return;
    emit(state.copyWith(status: TaskStatus.loading, clearMessage: true));
    try {
      final tasks = await _repository.getTasks(userId);
      emit(state.copyWith(status: TaskStatus.success, tasks: tasks));
    } on AppException catch (exception) {
      emit(state.copyWith(status: TaskStatus.failure, error: exception.error));
    }
  }

  /// Mengembalikan `null` jika sukses, atau kode error.
  Future<AppError?> addTask({
    required String title,
    String description = '',
    int estimatedPomodoros = 1,
    TaskPriority priority = TaskPriority.medium,
  }) async {
    final userId = state.userId;
    if (userId == null) return AppError.notLoggedIn;
    try {
      final task = await _repository.createTask(
        userId: userId,
        title: title,
        description: description,
        estimatedPomodoros: estimatedPomodoros,
        priority: priority,
      );
      emit(
        state.copyWith(
          status: TaskStatus.success,
          tasks: [task, ...state.tasks],
          activeTaskId: state.activeTaskId ?? task.id,
          feedback: TaskFeedback.added,
        ),
      );
      return null;
    } on AppException catch (exception) {
      return exception.error;
    }
  }

  Future<AppError?> updateTask(FocusTask task) async {
    try {
      final updated = await _repository.updateTask(task);
      _replace(updated, feedback: TaskFeedback.updated);
      return null;
    } on AppException catch (exception) {
      return exception.error;
    }
  }

  Future<void> toggleDone(FocusTask task) async {
    final error = await _silentUpdate(task.copyWith(isDone: !task.isDone));
    if (error != null) emit(state.copyWith(error: error));
  }

  Future<AppError?> deleteTask(FocusTask task) async {
    final userId = state.userId;
    if (userId == null) return AppError.notLoggedIn;
    try {
      await _repository.deleteTask(userId: userId, taskId: task.id);
      final isActive = state.activeTaskId == task.id;
      emit(
        state.copyWith(
          tasks: state.tasks.where((item) => item.id != task.id).toList(),
          clearActiveTask: isActive,
          feedback: TaskFeedback.deleted,
        ),
      );
      return null;
    } on AppException catch (exception) {
      emit(state.copyWith(error: exception.error));
      return exception.error;
    }
  }

  void setFilter(TaskFilter filter) => emit(state.copyWith(filter: filter));

  void setActiveTask(String? taskId) {
    emit(
      taskId == null
          ? state.copyWith(clearActiveTask: true)
          : state.copyWith(activeTaskId: taskId),
    );
  }

  /// Dipanggil saat satu sesi fokus selesai.
  Future<void> recordPomodoroForActiveTask() async {
    final task = state.activeTask;
    if (task == null || task.isDone) return;
    await _silentUpdate(
      task.copyWith(completedPomodoros: task.completedPomodoros + 1),
    );
  }

  void clearMessage() {
    if (state.hasMessage) emit(state.copyWith(clearMessage: true));
  }

  Future<AppError?> _silentUpdate(FocusTask task) async {
    try {
      final updated = await _repository.updateTask(task);
      _replace(updated);
      return null;
    } on AppException catch (exception) {
      return exception.error;
    }
  }

  void _replace(FocusTask updated, {TaskFeedback? feedback}) {
    emit(
      state.copyWith(
        tasks: [
          for (final task in state.tasks)
            if (task.id == updated.id) updated else task,
        ],
        feedback: feedback,
      ),
    );
  }
}
