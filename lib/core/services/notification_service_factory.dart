import 'notification_service.dart';
import 'notification_service_stub.dart'
    if (dart.library.io) 'notification_service_local.dart'
    as platform;

/// Memilih implementasi notifikasi sesuai platform.
/// Web -> [NoopNotificationService], Android/iOS -> flutter_local_notifications.
NotificationService createNotificationService() =>
    platform.createPlatformNotificationService();
