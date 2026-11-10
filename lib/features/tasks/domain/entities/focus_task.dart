import 'package:equatable/equatable.dart';

enum TaskPriority { low, medium, high }

/// Tugas yang dikerjakan dengan teknik Pomodoro.
class FocusTask extends Equatable {
  const FocusTask({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    this.estimatedPomodoros = 1,
    this.completedPomodoros = 0,
    this.priority = TaskPriority.medium,
    this.isDone = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String description;
  final int estimatedPomodoros;
  final int completedPomodoros;
  final TaskPriority priority;
  final bool isDone;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get progress => estimatedPomodoros == 0
      ? 0
      : (completedPomodoros / estimatedPomodoros).clamp(0, 1).toDouble();

  FocusTask copyWith({
    String? title,
    String? description,
    int? estimatedPomodoros,
    int? completedPomodoros,
    TaskPriority? priority,
    bool? isDone,
    DateTime? updatedAt,
  }) {
    return FocusTask(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    description,
    estimatedPomodoros,
    completedPomodoros,
    priority,
    isDone,
    createdAt,
    updatedAt,
  ];
}
