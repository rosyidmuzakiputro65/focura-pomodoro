import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/firebase/firebase_error_mapper.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/focus_task.dart';
import '../../domain/repositories/task_repository.dart';

/// CRUD tugas ke Cloud Firestore: `users/{uid}/tasks/{taskId}`.
///
/// - Data divalidasi di sini sebelum diunggah (dan divalidasi lagi oleh
///   Firestore Security Rules di server, lihat `firestore.rules`).
/// - Firestore menyimpan cache lokal, jadi aplikasi tetap bisa dipakai
///   offline; perubahan dikirim otomatis saat online kembali.
class FirestoreTaskRepository implements TaskRepository {
  FirestoreTaskRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Batas waktu menunggu konfirmasi server. Jika lewat (offline),
  /// perubahan tetap tersimpan di cache dan dikirim nanti.
  static const Duration _ackTimeout = Duration(seconds: 5);

  CollectionReference<Map<String, dynamic>> _tasks(String userId) =>
      _firestore.collection('users').doc(userId).collection('tasks');

  @override
  Future<List<FocusTask>> getTasks(String userId) async {
    try {
      final snapshot = await _tasks(userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => _fromDoc(userId, doc)).toList();
    } on FirebaseException catch (e) {
      throw NetworkException(mapFirebaseErrorCode(e.code));
    }
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
    final ref = _tasks(userId).doc();
    final task = FocusTask(
      id: ref.id,
      userId: userId,
      title: title.trim(),
      description: description.trim(),
      estimatedPomodoros: estimatedPomodoros,
      priority: priority,
      createdAt: now,
      updatedAt: now,
    );
    _validate(task);
    await _write(() => ref.set(_toMap(task)));
    return task;
  }

  @override
  Future<FocusTask> updateTask(FocusTask task) async {
    final updated = task.copyWith(
      title: task.title.trim(),
      description: task.description.trim(),
      updatedAt: DateTime.now(),
    );
    _validate(updated);
    await _write(() => _tasks(task.userId).doc(task.id).update(_toMap(updated)));
    return updated;
  }

  @override
  Future<void> deleteTask({required String userId, required String taskId}) =>
      _write(() => _tasks(userId).doc(taskId).delete());

  Future<void> _write(Future<void> Function() action) async {
    try {
      await action().timeout(_ackTimeout);
    } on TimeoutException {
      // Offline: sudah tersimpan di cache lokal Firestore.
    } on FirebaseException catch (e) {
      throw NetworkException(mapFirebaseErrorCode(e.code));
    }
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
    'title': task.title,
    'description': task.description,
    'estimatedPomodoros': task.estimatedPomodoros,
    'completedPomodoros': task.completedPomodoros,
    'priority': task.priority.name,
    'isDone': task.isDone,
    'createdAt': Timestamp.fromDate(task.createdAt),
    'updatedAt': Timestamp.fromDate(task.updatedAt),
  };

  static FocusTask _fromDoc(
    String userId,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final map = doc.data();
    DateTime date(Object? value) =>
        value is Timestamp ? value.toDate() : DateTime.now();
    return FocusTask(
      id: doc.id,
      userId: userId,
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      estimatedPomodoros: (map['estimatedPomodoros'] as num?)?.toInt() ?? 1,
      completedPomodoros: (map['completedPomodoros'] as num?)?.toInt() ?? 0,
      priority: TaskPriority.values.firstWhere(
        (value) => value.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      isDone: (map['isDone'] as bool?) ?? false,
      createdAt: date(map['createdAt']),
      updatedAt: date(map['updatedAt']),
    );
  }
}
