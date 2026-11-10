import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:hive_ce/hive.dart';

import '../../../../core/constants/demo_account.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Autentikasi dengan database lokal (Hive).
///
/// Password tidak pernah disimpan dalam bentuk asli: setiap akun punya
/// salt acak dan yang disimpan hanya hash SHA-256 dari `salt:password`.
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository({required Box<dynamic> usersBox, required Box<dynamic> sessionBox})
    : _users = usersBox,
      _session = sessionBox;

  final Box<dynamic> _users;
  final Box<dynamic> _session;

  static const String _currentUserKey = 'currentUserEmail';

  /// Membuat akun demo supaya dosen/penguji bisa langsung login.
  Future<void> ensureDemoAccount() async {
    if (_users.containsKey(DemoAccount.email)) return;
    await _saveUser(
      name: DemoAccount.name,
      email: DemoAccount.email,
      password: DemoAccount.password,
    );
  }

  @override
  Future<AppUser?> currentUser() async {
    final email = _session.get(_currentUserKey) as String?;
    if (email == null) return null;
    final record = _users.get(email);
    if (record == null) {
      await _session.delete(_currentUserKey);
      return null;
    }
    return _toUser(Map<String, dynamic>.from(record as Map));
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Validasi ulang di lapisan data sebelum menyimpan ke database.
    final error =
        Validators.name(name) ??
        Validators.email(email) ??
        Validators.newPassword(password);
    if (error != null) throw ValidationException(error);

    final key = _normalize(email);
    if (_users.containsKey(key)) {
      throw const AuthException(AppError.emailAlreadyRegistered);
    }

    final user = await _saveUser(name: name.trim(), email: key, password: password);
    await _session.put(_currentUserKey, key);
    return user;
  }

  @override
  Future<AppUser> login({required String email, required String password}) async {
    final error = Validators.email(email) ?? Validators.requiredPassword(password);
    if (error != null) throw ValidationException(error);

    final key = _normalize(email);
    final record = _users.get(key);
    if (record == null) {
      throw const AuthException(AppError.wrongCredentials);
    }
    final data = Map<String, dynamic>.from(record as Map);
    final expected = data['passwordHash'] as String;
    if (_hash(data['salt'] as String, password) != expected) {
      throw const AuthException(AppError.wrongCredentials);
    }
    await _session.put(_currentUserKey, key);
    return _toUser(data);
  }

  @override
  Future<AppUser> loginWithGoogle() async =>
      throw const AuthException(AppError.googleSignInUnavailable);

  @override
  Future<void> logout() => _session.delete(_currentUserKey);

  Future<AppUser> _saveUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final salt = _newSalt();
    final now = DateTime.now();
    final data = <String, dynamic>{
      'id': IdGenerator.newId(),
      'name': name,
      'email': email,
      'salt': salt,
      'passwordHash': _hash(salt, password),
      'createdAt': now.toIso8601String(),
    };
    await _users.put(email, data);
    return _toUser(data);
  }

  AppUser _toUser(Map<String, dynamic> data) => AppUser(
    id: data['id'] as String,
    name: data['name'] as String,
    email: data['email'] as String,
    createdAt: DateTime.parse(data['createdAt'] as String),
  );

  static String _normalize(String email) => email.trim().toLowerCase();

  static String _newSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String _hash(String salt, String password) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();
}
