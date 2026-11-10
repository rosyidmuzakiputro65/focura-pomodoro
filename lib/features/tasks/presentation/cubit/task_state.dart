part of 'task_cubit.dart';

enum TaskStatus { initial, loading, success, failure }

enum TaskFilter { all, pending, completed }

/// Umpan balik sukses yang ditampilkan sebagai SnackBar (diterjemahkan di UI).
enum TaskFeedback { added, updated, deleted }

class TaskState extends Equatable {
  const TaskState({
    this.status = TaskStatus.initial,
    this.userId,
    this.tasks = const [],
    this.filter = TaskFilter.all,
    this.activeTaskId,
    this.feedback,
    this.error,
  });

  final TaskStatus status;
  final String? userId;
  final List<FocusTask> tasks;
  final TaskFilter filter;
  final String? activeTaskId;
  final TaskFeedback? feedback;
  final AppError? error;

  bool get hasMessage => feedback != null || error != null;

  List<FocusTask> get visibleTasks => switch (filter) {
    TaskFilter.all => tasks,
    TaskFilter.pending => tasks.where((task) => !task.isDone).toList(),
    TaskFilter.completed => tasks.where((task) => task.isDone).toList(),
  };

  List<FocusTask> get pendingTasks =>
      tasks.where((task) => !task.isDone).toList();

  int get completedCount => tasks.where((task) => task.isDone).length;

  FocusTask? get activeTask {
    for (final task in tasks) {
      if (task.id == activeTaskId) return task;
    }
    return null;
  }

  TaskState copyWith({
    TaskStatus? status,
    String? userId,
    List<FocusTask>? tasks,
    TaskFilter? filter,
    String? activeTaskId,
    bool clearActiveTask = false,
    TaskFeedback? feedback,
    AppError? error,
    bool clearMessage = false,
  }) {
    return TaskState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      activeTaskId: clearActiveTask ? null : (activeTaskId ?? this.activeTaskId),
      feedback: clearMessage ? null : (feedback ?? this.feedback),
      error: clearMessage ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    status,
    userId,
    tasks,
    filter,
    activeTaskId,
    feedback,
    error,
  ];
}
