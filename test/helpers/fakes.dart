import 'package:flutter_application_1/core/errors/app_exception.dart';
import 'package:flutter_application_1/core/services/notification_service.dart';
import 'package:flutter_application_1/features/music/domain/entities/focus_track.dart';
import 'package:flutter_application_1/features/music/domain/repositories/music_repository.dart';
import 'package:flutter_application_1/features/quotes/domain/entities/quote.dart';
import 'package:flutter_application_1/features/quotes/domain/repositories/quote_repository.dart';
import 'package:flutter_application_1/features/quotes/domain/repositories/translation_repository.dart';
import 'package:flutter_application_1/features/settings/domain/entities/timer_settings.dart';
import 'package:flutter_application_1/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_application_1/features/stats/domain/entities/focus_session_record.dart';
import 'package:flutter_application_1/features/stats/domain/repositories/session_repository.dart';
import 'package:flutter_application_1/features/tasks/domain/entities/focus_task.dart';
import 'package:flutter_application_1/features/tasks/domain/repositories/task_repository.dart';

class RecordingNotificationService extends NoopNotificationService {
  int scheduled = 0;
  int cancelled = 0;
  DateTime? lastScheduledAt;

  @override
  Future<void> scheduleSessionEnd({
    required DateTime at,
    required String title,
    required String body,
  }) async {
    scheduled++;
    lastScheduledAt = at;
  }

  @override
  Future<void> cancelSessionEnd() async {
    cancelled++;
  }
}

class InMemoryTaskRepository implements TaskRepository {
  final Map<String, FocusTask> _tasks = {};
  int _counter = 0;

  @override
  Future<List<FocusTask>> getTasks(String userId) async =>
      _tasks.values.where((t) => t.userId == userId).toList();

  @override
  Future<FocusTask> createTask({
    required String userId,
    required String title,
    String description = '',
    int estimatedPomodoros = 1,
    TaskPriority priority = TaskPriority.medium,
  }) async {
    if (title.trim().length < 3) {
      throw const ValidationException(AppError.taskTitleTooShort);
    }
    final now = DateTime(2026);
    final task = FocusTask(
      id: 't${_counter++}',
      userId: userId,
      title: title.trim(),
      description: description,
      estimatedPomodoros: estimatedPomodoros,
      priority: priority,
      createdAt: now,
      updatedAt: now,
    );
    _tasks[task.id] = task;
    return task;
  }

  @override
  Future<FocusTask> updateTask(FocusTask task) async {
    if (!_tasks.containsKey(task.id)) {
      throw const NotFoundException(AppError.taskNotFound);
    }
    _tasks[task.id] = task;
    return task;
  }

  @override
  Future<void> deleteTask({required String userId, required String taskId}) async {
    _tasks.remove(taskId);
  }
}

class InMemorySessionRepository implements SessionRepository {
  final List<FocusSessionRecord> sessions = [];

  @override
  Future<FocusSessionRecord> addSession({
    required String userId,
    required int minutes,
    String? taskTitle,
  }) async {
    final record = FocusSessionRecord(
      id: '${sessions.length}',
      userId: userId,
      minutes: minutes,
      completedAt: DateTime.now(),
      taskTitle: taskTitle,
    );
    sessions.add(record);
    return record;
  }

  @override
  Future<List<FocusSessionRecord>> getSessions(String userId) async =>
      sessions.where((s) => s.userId == userId).toList();
}

class FakeQuoteRepository implements QuoteRepository {
  FakeQuoteRepository({this.total = 40});

  final int total;
  int calls = 0;

  @override
  Future<QuotePage> fetchQuotes({required int skip, required int limit}) async {
    calls++;
    final end = (skip + limit).clamp(0, total);
    return QuotePage(
      quotes: [
        for (var i = skip; i < end; i++)
          Quote(id: i, text: 'Kutipan $i', author: 'Penulis $i'),
      ],
      total: total,
      skip: skip,
    );
  }
}

class InMemorySettingsRepository implements SettingsRepository {
  TimerSettings timer = const TimerSettings();
  bool onboardingDone = true;
  String? languageCode;

  @override
  Future<TimerSettings> loadTimerSettings() async => timer;

  @override
  Future<void> saveTimerSettings(TimerSettings settings) async {
    timer = settings;
  }

  @override
  Future<bool> isOnboardingDone() async => onboardingDone;

  @override
  Future<void> setOnboardingDone() async {
    onboardingDone = true;
  }

  @override
  Future<String?> loadLanguageCode() async => languageCode;

  @override
  Future<void> saveLanguageCode(String code) async {
    languageCode = code;
  }
}

class InMemoryMusicRepository implements MusicRepository {
  MusicPreferences saved = const MusicPreferences();

  @override
  Future<MusicPreferences> load() async => saved;

  @override
  Future<void> save(MusicPreferences preferences) async {
    saved = preferences;
  }
}

class FakeTranslationRepository implements TranslationRepository {
  FakeTranslationRepository({this.fail = false});

  bool fail;
  int calls = 0;

  @override
  Future<String> translate(
    String text, {
    String from = 'en',
    required String to,
  }) async {
    calls++;
    if (fail) throw const NetworkException(AppError.translationUnavailable);
    return '[$to] $text';
  }
}
