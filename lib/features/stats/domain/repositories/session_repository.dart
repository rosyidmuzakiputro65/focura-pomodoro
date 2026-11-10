import '../entities/focus_session_record.dart';

abstract class SessionRepository {
  Future<FocusSessionRecord> addSession({
    required String userId,
    required int minutes,
    String? taskTitle,
  });

  Future<List<FocusSessionRecord>> getSessions(String userId);
}
