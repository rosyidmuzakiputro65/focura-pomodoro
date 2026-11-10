import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/firebase/firebase_error_mapper.dart';
import '../../domain/entities/focus_session_record.dart';
import '../../domain/repositories/session_repository.dart';

/// Riwayat sesi fokus di Firestore: `users/{uid}/sessions/{id}`.
class FirestoreSessionRepository implements SessionRepository {
  FirestoreSessionRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _sessions(String userId) =>
      _firestore.collection('users').doc(userId).collection('sessions');

  @override
  Future<FocusSessionRecord> addSession({
    required String userId,
    required int minutes,
    String? taskTitle,
  }) async {
    if (minutes < 1 || minutes > 180) {
      throw const ValidationException(AppError.sessionDurationInvalid);
    }
    final ref = _sessions(userId).doc();
    final record = FocusSessionRecord(
      id: ref.id,
      userId: userId,
      minutes: minutes,
      completedAt: DateTime.now(),
      taskTitle: taskTitle,
    );
    try {
      await ref
          .set({
            'minutes': minutes,
            'completedAt': Timestamp.fromDate(record.completedAt),
            'taskTitle': taskTitle,
          })
          .timeout(const Duration(seconds: 5));
    } on TimeoutException {
      // Offline: tersimpan di cache, dikirim saat online.
    } on FirebaseException catch (e) {
      throw NetworkException(mapFirebaseErrorCode(e.code));
    }
    return record;
  }

  @override
  Future<List<FocusSessionRecord>> getSessions(String userId) async {
    try {
      // Cukup 60 hari terakhir untuk statistik harian & mingguan.
      final since = DateTime.now().subtract(const Duration(days: 60));
      final snapshot = await _sessions(userId)
          .where('completedAt', isGreaterThan: Timestamp.fromDate(since))
          .get();
      return snapshot.docs.map((doc) {
        final map = doc.data();
        return FocusSessionRecord(
          id: doc.id,
          userId: userId,
          minutes: (map['minutes'] as num?)?.toInt() ?? 0,
          completedAt: (map['completedAt'] as Timestamp?)?.toDate() ??
              DateTime.now(),
          taskTitle: map['taskTitle'] as String?,
        );
      }).toList();
    } on FirebaseException catch (e) {
      throw NetworkException(mapFirebaseErrorCode(e.code));
    }
  }
}
