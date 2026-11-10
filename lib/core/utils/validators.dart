import '../errors/app_exception.dart';

/// Aturan validasi yang dipakai di form (UI) **dan** di repository
/// (sebelum data ditulis ke database). Setiap fungsi mengembalikan `null`
/// jika valid, atau [AppError] jika tidak valid. Teksnya diterjemahkan di UI.
class Validators {
  const Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.[a-zA-Z]{2,}$',
  );

  static const int nameMin = 3;
  static const int nameMax = 50;
  static const int passwordMin = 6;
  static const int passwordMax = 64;
  static const int taskTitleMin = 3;
  static const int taskTitleMax = 80;
  static const int taskDescriptionMax = 300;
  static const int pomodoroMin = 1;
  static const int pomodoroMax = 10;

  static AppError? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return AppError.nameRequired;
    if (text.length < nameMin) return AppError.nameTooShort;
    if (text.length > nameMax) return AppError.nameTooLong;
    return null;
  }

  static AppError? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return AppError.emailRequired;
    if (!_emailRegex.hasMatch(text)) return AppError.emailInvalid;
    return null;
  }

  /// Password untuk login: cukup tidak kosong.
  static AppError? requiredPassword(String? value) {
    if (value == null || value.isEmpty) return AppError.passwordRequired;
    return null;
  }

  /// Password untuk register: minimal 6 karakter, mengandung huruf dan angka.
  static AppError? newPassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return AppError.passwordRequired;
    if (text.length < passwordMin) return AppError.passwordTooShort;
    if (text.length > passwordMax) return AppError.passwordTooLong;
    if (!RegExp(r'[A-Za-z]').hasMatch(text) || !RegExp(r'\d').hasMatch(text)) {
      return AppError.passwordWeak;
    }
    return null;
  }

  static AppError? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return AppError.confirmPasswordRequired;
    if (value != password) return AppError.confirmPasswordMismatch;
    return null;
  }

  static AppError? taskTitle(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return AppError.taskTitleRequired;
    if (text.length < taskTitleMin) return AppError.taskTitleTooShort;
    if (text.length > taskTitleMax) return AppError.taskTitleTooLong;
    return null;
  }

  static AppError? taskDescription(String? value) {
    final text = value?.trim() ?? '';
    if (text.length > taskDescriptionMax) return AppError.taskDescriptionTooLong;
    return null;
  }

  static AppError? estimatedPomodoros(int? value) {
    if (value == null) return AppError.estimateRequired;
    if (value < pomodoroMin || value > pomodoroMax) {
      return AppError.estimateOutOfRange;
    }
    return null;
  }

  static AppError? durationMinutes(int? value, {int min = 1, int max = 90}) {
    if (value == null || value < min || value > max) {
      return AppError.durationInvalid;
    }
    return null;
  }
}
