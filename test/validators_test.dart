import 'package:flutter_application_1/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    test('email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('bukan-email'), isNotNull);
      expect(Validators.email('rod@unida.gontor.ac.id'), isNull);
    });

    test('password baru wajib huruf dan angka, minimal 6', () {
      expect(Validators.newPassword('abc'), isNotNull);
      expect(Validators.newPassword('abcdef'), isNotNull);
      expect(Validators.newPassword('123456'), isNotNull);
      expect(Validators.newPassword('abc123'), isNull);
    });

    test('konfirmasi password harus sama', () {
      expect(Validators.confirmPassword('abc123', 'abc124'), isNotNull);
      expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
    });

    test('judul tugas 3-80 karakter', () {
      expect(Validators.taskTitle('  '), isNotNull);
      expect(Validators.taskTitle('ab'), isNotNull);
      expect(Validators.taskTitle('a' * 81), isNotNull);
      expect(Validators.taskTitle('Belajar Flutter'), isNull);
    });

    test('estimasi pomodoro 1-10', () {
      expect(Validators.estimatedPomodoros(0), isNotNull);
      expect(Validators.estimatedPomodoros(11), isNotNull);
      expect(Validators.estimatedPomodoros(4), isNull);
    });
  });
}
