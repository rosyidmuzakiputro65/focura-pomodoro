import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'notification_service.dart';

NotificationService createPlatformNotificationService() {
  if (Platform.isAndroid || Platform.isIOS) {
    return LocalNotificationService();
  }
  return const NoopNotificationService();
}

/// Local notification memakai package `flutter_local_notifications`.
class LocalNotificationService implements NotificationService {
  LocalNotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const int _sessionEndId = 1001;
  static const int _instantId = 1002;

  String _channelName = 'Timer Pomodoro';
  String _channelDescription =
      'Pemberitahuan saat sesi fokus atau istirahat selesai';

  NotificationDetails get _details => NotificationDetails(
    android: AndroidNotificationDetails(
      'focura_timer',
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: const DarwinNotificationDetails(),
  );

  @override
  void setChannelText({required String name, required String description}) {
    _channelName = name;
    _channelDescription = description;
  }

  @override
  Future<void> init() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      await _plugin.initialize(settings);
      _initialized = true;
    } catch (error) {
      debugPrint('Gagal inisialisasi notifikasi: $error');
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      if (Platform.isAndroid) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        return await android?.requestNotificationsPermission() ?? true;
      }
      if (Platform.isIOS) {
        final ios = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        return await ios?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            true;
      }
    } catch (error) {
      debugPrint('Gagal meminta izin notifikasi: $error');
    }
    return true;
  }

  @override
  Future<void> scheduleSessionEnd({
    required DateTime at,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(_sessionEndId);
      await _plugin.zonedSchedule(
        _sessionEndId,
        title,
        body,
        tz.TZDateTime.from(at.toUtc(), tz.UTC),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (error) {
      debugPrint('Gagal menjadwalkan notifikasi: $error');
    }
  }

  @override
  Future<void> cancelSessionEnd() async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(_sessionEndId);
    } catch (error) {
      debugPrint('Gagal membatalkan notifikasi: $error');
    }
  }

  @override
  Future<void> showNow({required String title, required String body}) async {
    if (!_initialized) return;
    try {
      await _plugin.show(_instantId, title, body, _details);
    } catch (error) {
      debugPrint('Gagal menampilkan notifikasi: $error');
    }
  }
}
