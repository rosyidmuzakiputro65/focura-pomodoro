/// Info backend yang sedang dipakai (ditampilkan di Profil untuk diagnosis).
class BackendInfo {
  BackendInfo._();

  static String name = '-';

  /// Pesan error jika Firebase gagal dinyalakan (mode lokal).
  static String? error;
}
