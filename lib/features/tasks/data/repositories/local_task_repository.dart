import 'package:hive_ce/hive.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/focus_task.dart';
import '../../domain/repositories/task_repository.dart';

/// CRUD tugas ke database lokal Hive. Setiap data divalidasi ulang di
/// sini sebelum ditulis, jadi data tidak valid tidak pernah masuk database
/// walaupun form di UI dilewati.
class LocalTaskRepository implements TaskRepository {
  LocalTaskRepository(this._box);

  final Box<dynamic> _box;

  @override
  Future<List<FocusTask>> getTasks(String userId) async {
    final tasks = _box.values
        .map((raw) => _fromMap(Map<String, dynamic>.from(raw as Map)))
        .where((task) => task.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tasks;
  }

  @override
  Future<FocusTask> createTask({
    required String userId,
    required String title,
    String description = '',
    int estimatedPomodoros = 1,
    TaskPriority priority = TaskPriority.medium,
  }) async {
    final now = DateTime.now();
    final task = FocusTask(
      id: IdGenerator.newId(),
      userId: userId,
      title: title.trim(),
      description: description.trim(),
      estimatedPomodoros: estimatedPomodoros,
      priority: priority,
      createdAt: now,
      updatedAt: now,
    );
    _validate(task);
    await _box.put(task.id, _toMap(task));
    return task;
  }

  @override
  Future<FocusTask> updateTask(FocusTask task) async {
    final existing = _box.get(task.id);
    if (existing == null) {
      throw const NotFoundException(AppError.taskNotFound);
    }
    final owner = Map<String, dynamic>.from(existing as Map)['userId'];
    if (owner != task.userId) {
      throw const AuthException(AppError.notOwner);
    }
    final updated = task.copyWith(
      title: task.title.trim(),
      description: task.description.trim(),
      updatedAt: DateTime.now(),
    );
    _validate(updated);
    await _box.put(updated.id, _toMap(updated));
    return updated;
  }

  @override
  Future<void> deleteTask({required String userId, required String taskId}) async {
    final existing = _box.get(taskId);
    if (existing == null) {
      throw const NotFoundException(AppError.taskNotFound);
    }
    final owner = Map<String, dynamic>.from(existing as Map)['userId'];
    if (owner != userId) {
      throw const AuthException(AppError.notOwner);
    }
    await _box.delete(taskId);
  }

  void _validate(FocusTask task) {
    final error =
        Validators.taskTitle(task.title) ??
        Validators.taskDescription(task.description) ??
        Validators.estimatedPomodoros(task.estimatedPomodoros);
    if (error != null) throw ValidationException(error);
    if (task.completedPomodoros < 0) {
      throw const ValidationException(AppError.pomodoroCountInvalid);
    }
  }

  static Map<String, dynamic> _toMap(FocusTask task) => {
    'id': task.id,
    'userId': task.userId,
    'title': task.title,
    'description': task.description,
    'estimatedPomodoros': task.estimatedPomodoros,
    'completedPomodoros': task.completedPomodoros,
    'priority': task.priority.name,
    'isDone': task.isDone,
    'createdAt': task.createdAt.toIso8601String(),
    'updatedAt': task.updatedAt.toIso8601String(),
  };

  static FocusTask _fromMap(Map<String, dynamic> map) => FocusTask(
    id: map['id'] as String,
    userId: map['userId'] as String,
    title: map['title'] as String,
    description: (map['description'] as String?) ?? '',
    estimatedPomodoros: (map['estimatedPomodoros'] as num?)?.toInt() ?? 1,
    completedPomodoros: (map['completedPomodoros'] as num?)?.toInt() ?? 0,
    priority: TaskPriority.values.firstWhere(
      (value) => value.name == map['priority'],
      orElse: () => TaskPriority.medium,
    ),
    isDone: (map['isDone'] as bool?) ?? false,
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: DateTime.parse(map['updatedAt'] as String),
  );
}
