import '../entities/focus_task.dart';

/// Kontrak CRUD tugas.
abstract class TaskRepository {
  /// Read: semua tugas milik [userId], terbaru di atas.
  Future<List<FocusTask>> getTasks(String userId);

  /// Create
  Future<FocusTask> createTask({
    required String userId,
    required String title,
    String description,
    int estimatedPomodoros,
    TaskPriority priority,
  });

  /// Update
  Future<FocusTask> updateTask(FocusTask task);

  /// Delete
  Future<void> deleteTask({required String userId, required String taskId});
}
