import '../entities/app_user.dart';

/// Kontrak autentikasi. UI dan Cubit tidak tahu data disimpan di mana.
abstract class AuthRepository {
  /// Pengguna yang sedang login, atau `null` jika belum login.
  Future<AppUser?> currentUser();

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AppUser> login({required String email, required String password});

  /// Masuk dengan akun Google.
  Future<AppUser> loginWithGoogle();

  Future<void> logout();
}
