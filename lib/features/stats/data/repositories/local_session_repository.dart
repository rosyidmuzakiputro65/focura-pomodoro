import 'package:hive_ce/hive.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/id_generator.dart';
import '../../domain/entities/focus_session_record.dart';
import '../../domain/repositories/session_repository.dart';

class LocalSessionRepository implements SessionRepository {
  LocalSessionRepository(this._box);

  final Box<dynamic> _box;

  @override
  Future<FocusSessionRecord> addSession({
    required String userId,
    required int minutes,
    String? taskTitle,
  }) async {
    if (minutes < 1 || minutes > 180) {
      throw const ValidationException(AppError.sessionDurationInvalid);
    }
    final record = FocusSessionRecord(
      id: IdGenerator.newId(),
      userId: userId,
      minutes: minutes,
      completedAt: DateTime.now(),
      taskTitle: taskTitle,
    );
    await _box.put(record.id, {
      'id': record.id,
      'userId': record.userId,
      'minutes': record.minutes,
      'completedAt': record.completedAt.toIso8601String(),
      'taskTitle': record.taskTitle,
    });
    return record;
  }

  @override
  Future<List<FocusSessionRecord>> getSessions(String userId) async {
    return _box.values
        .map((raw) => Map<String, dynamic>.from(raw as Map))
        .where((map) => map['userId'] == userId)
        .map(
          (map) => FocusSessionRecord(
            id: map['id'] as String,
            userId: map['userId'] as String,
            minutes: (map['minutes'] as num).toInt(),
            completedAt: DateTime.parse(map['completedAt'] as String),
            taskTitle: map['taskTitle'] as String?,
          ),
        )
        .toList();
  }
}
