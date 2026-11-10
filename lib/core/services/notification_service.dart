/// Kontrak layanan notifikasi. Business logic (PomodoroCubit) hanya
/// bergantung pada kelas abstrak ini, bukan pada plugin secara langsung.
abstract class NotificationService {
  Future<void> init();

  /// Nama & deskripsi channel notifikasi Android sesuai bahasa aplikasi.
  void setChannelText({required String name, required String description});

  /// Meminta izin notifikasi (Android 13+ / iOS). Mengembalikan `true`
  /// jika izin diberikan atau tidak diperlukan.
  Future<bool> requestPermission();

  /// Menjadwalkan notifikasi saat sesi berakhir, sehingga tetap muncul
  /// walaupun aplikasi sedang di background.
  Future<void> scheduleSessionEnd({
    required DateTime at,
    required String title,
    required String body,
  });

  Future<void> cancelSessionEnd();

  Future<void> showNow({required String title, required String body});
}

/// Implementasi kosong untuk platform yang tidak mendukung notifikasi
/// lokal (misalnya Web) dan untuk pengujian.
class NoopNotificationService implements NotificationService {
  const NoopNotificationService();

  @override
  Future<void> init() async {}

  @override
  void setChannelText({required String name, required String description}) {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> scheduleSessionEnd({
    required DateTime at,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancelSessionEnd() async {}

  @override
  Future<void> showNow({required String title, required String body}) async {}
}
