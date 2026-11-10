import 'dart:io';

import 'package:flutter_application_1/core/errors/app_exception.dart';
import 'package:flutter_application_1/features/auth/data/repositories/local_auth_repository.dart';
import 'package:flutter_application_1/features/tasks/data/repositories/local_task_repository.dart';
import 'package:flutter_application_1/features/tasks/domain/entities/focus_task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('focura_test');
    Hive.init(dir.path);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    if (dir.existsSync()) await dir.delete(recursive: true);
  });

  group('LocalAuthRepository', () {
    late LocalAuthRepository repo;

    setUp(() async {
      repo = LocalAuthRepository(
        usersBox: await Hive.openBox<dynamic>('users'),
        sessionBox: await Hive.openBox<dynamic>('session'),
      );
    });

    test('register, logout, lalu login kembali', () async {
      final user = await repo.register(
        name: 'Rosyid',
        email: 'Rod@Mail.com',
        password: 'abc123',
      );
      expect(user.email, 'rod@mail.com');
      expect(await repo.currentUser(), user);

      await repo.logout();
      expect(await repo.currentUser(), isNull);

      final again = await repo.login(email: 'rod@mail.com', password: 'abc123');
      expect(again.id, user.id);
    });

    test('password tidak disimpan dalam bentuk asli', () async {
      final box = await Hive.openBox<dynamic>('users');
      await repo.register(name: 'Rosyid', email: 'a@b.co', password: 'abc123');
      final record = Map<String, dynamic>.from(box.get('a@b.co') as Map);
      expect(record.values, isNot(contains('abc123')));
    });

    test('password salah ditolak', () async {
      await repo.register(name: 'Rosyid', email: 'a@b.co', password: 'abc123');
      expect(
        () => repo.login(email: 'a@b.co', password: 'salah123'),
        throwsA(isA<AuthException>()),
      );
    });

    test('data tidak valid ditolak sebelum disimpan', () async {
      expect(
        () => repo.register(name: 'R', email: 'x', password: '1'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('email ganda ditolak', () async {
      await repo.register(name: 'Rosyid', email: 'a@b.co', password: 'abc123');
      expect(
        () => repo.register(name: 'Lain', email: 'A@B.co', password: 'abc123'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('LocalTaskRepository (CRUD)', () {
    late LocalTaskRepository repo;

    setUp(() async {
      repo = LocalTaskRepository(await Hive.openBox<dynamic>('tasks'));
    });

    test('create, read, update, delete', () async {
      final created = await repo.createTask(
        userId: 'u1',
        title: 'Belajar Cubit',
        estimatedPomodoros: 3,
        priority: TaskPriority.high,
      );
      expect((await repo.getTasks('u1')).single.title, 'Belajar Cubit');
      expect(await repo.getTasks('u2'), isEmpty);

      final updated = await repo.updateTask(
        created.copyWith(title: 'Belajar BLoC', isDone: true),
      );
      expect(updated.isDone, isTrue);
      expect((await repo.getTasks('u1')).single.title, 'Belajar BLoC');

      await repo.deleteTask(userId: 'u1', taskId: created.id);
      expect(await repo.getTasks('u1'), isEmpty);
    });

    test('judul kosong / estimasi di luar batas ditolak', () async {
      expect(
        () => repo.createTask(userId: 'u1', title: '  '),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => repo.createTask(userId: 'u1', title: 'Valid', estimatedPomodoros: 20),
        throwsA(isA<ValidationException>()),
      );
    });

    test('tidak bisa menghapus tugas milik user lain', () async {
      final task = await repo.createTask(userId: 'u1', title: 'Rahasia');
      expect(
        () => repo.deleteTask(userId: 'u2', taskId: task.id),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
