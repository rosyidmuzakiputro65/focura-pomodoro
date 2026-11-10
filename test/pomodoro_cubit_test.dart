import 'package:flutter_application_1/features/timer/presentation/cubit/pomodoro_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';

void main() {
  group('PomodoroCubit', () {
    test('mulai dengan durasi fokus yang dikonfigurasi', () async {
      final cubit = PomodoroCubit(focusDuration: const Duration(minutes: 20));

      expect(cubit.state.mode, PomodoroMode.focus);
      expect(cubit.state.remainingSeconds, 1200);
      expect(cubit.state.timeText, '20:00');
      expect(cubit.state.isRunning, isFalse);

      await cubit.close();
    });

    testWidgets('menghitung mundur dan menyimpan sisa waktu saat dijeda', (
      tester,
    ) async {
      var now = DateTime.utc(2026);
      final notifications = RecordingNotificationService();
      final cubit = PomodoroCubit(
        focusDuration: const Duration(seconds: 10),
        now: () => now,
        notifications: notifications,
        notificationCopy: const SessionNotificationCopy(
          focusDoneTitle: 'Focus done',
          focusDoneBody: 'Take a break',
          breakDoneTitle: 'Break over',
          breakDoneBody: 'Back to work',
        ),
      );

      cubit.start();
      expect(notifications.scheduled, 1);
      expect(notifications.lastScheduledAt, DateTime.utc(2026).add(const Duration(seconds: 10)));

      now = now.add(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));

      expect(cubit.state.remainingSeconds, 8);
      cubit.pause();
      expect(cubit.state.isRunning, isFalse);
      expect(cubit.state.remainingSeconds, 8);
      expect(notifications.cancelled, 1);

      await cubit.close();
    });

    testWidgets('istirahat panjang setelah empat sesi fokus', (tester) async {
      var now = DateTime.utc(2026);
      final cubit = PomodoroCubit(
        focusDuration: const Duration(seconds: 1),
        shortBreakDuration: const Duration(seconds: 2),
        longBreakDuration: const Duration(seconds: 3),
        now: () => now,
      );

      for (var session = 1; session <= 4; session++) {
        cubit.start();
        now = now.add(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));

        final expectedBreak = session == 4
            ? PomodoroMode.longBreak
            : PomodoroMode.shortBreak;
        expect(cubit.state.mode, expectedBreak);
        expect(cubit.state.completedFocusSessions, session);
        expect(cubit.state.lastFinishedMode, PomodoroMode.focus);

        if (session < 4) cubit.skip();
      }

      expect(cubit.state.remainingSeconds, 3);
      expect(cubit.state.isRunning, isFalse);
      expect(cubit.state.finishedCount, 4);

      await cubit.close();
    });

    test('updateDurations memperbarui timer yang belum berjalan', () async {
      final cubit = PomodoroCubit();
      cubit.updateDurations(
        focus: const Duration(minutes: 50),
        shortBreak: const Duration(minutes: 10),
        longBreak: const Duration(minutes: 30),
      );
      expect(cubit.state.timeText, '50:00');
      cubit.selectMode(PomodoroMode.longBreak);
      expect(cubit.state.timeText, '30:00');
      await cubit.close();
    });
  });
}
