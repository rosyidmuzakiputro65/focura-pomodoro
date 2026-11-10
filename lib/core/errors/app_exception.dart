/// Kode kesalahan aplikasi. Lapisan data/logic hanya mengirim kode ini,
/// teks yang tampil ke pengguna diterjemahkan di UI lewat `AppStrings.error`
/// sehingga pesan error ikut berganti bahasa.
enum AppError {
  // Validasi
  nameRequired,
  nameTooShort,
  nameTooLong,
  emailRequired,
  emailInvalid,
  passwordRequired,
  passwordTooShort,
  passwordTooLong,
  passwordWeak,
  confirmPasswordRequired,
  confirmPasswordMismatch,
  taskTitleRequired,
  taskTitleTooShort,
  taskTitleTooLong,
  taskDescriptionTooLong,
  estimateRequired,
  estimateOutOfRange,
  durationInvalid,
  sessionDurationInvalid,
  pomodoroCountInvalid,
  // Autentikasi & akses
  emailAlreadyRegistered,
  wrongCredentials,
  notOwner,
  notLoggedIn,
  tooManyAttempts,
  permissionDenied,
  authProviderDisabled,
  signInCancelled,
  googleSignInFailed,
  googleSignInUnavailable,
  // Data
  taskNotFound,
  // Jaringan
  networkTimeout,
  networkServer,
  networkBadData,
  networkOffline,
  translationUnavailable,
  // Lainnya
  unknown,
}

/// Exception dasar aplikasi. Lapisan data melempar turunan kelas ini,
/// lapisan presentasi (Cubit) meneruskan [error] ke UI.
abstract class AppException implements Exception {
  const AppException(this.error);

  final AppError error;

  @override
  String toString() => '$runtimeType(${error.name})';
}

/// Data tidak lolos validasi sebelum disimpan ke database.
class ValidationException extends AppException {
  const ValidationException(super.error);
}

/// Gagal login / register / tidak berhak mengakses data.
class AuthException extends AppException {
  const AuthException(super.error);
}

/// Gagal mengambil data dari internet dan tidak ada cache.
class NetworkException extends AppException {
  const NetworkException(super.error);
}

/// Data yang dicari tidak ada di database.
class NotFoundException extends AppException {
  const NotFoundException(super.error);
}
