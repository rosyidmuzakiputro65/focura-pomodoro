import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

/// Mengelola status login. UI cukup memanggil method di sini dan
/// mendengarkan [AuthState]; tidak ada logika autentikasi di widget.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<void> checkSession() async {
    final user = await _repository.currentUser();
    emit(
      user == null
          ? const AuthState(status: AuthStatus.unauthenticated)
          : AuthState(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> login({required String email, required String password}) {
    return _submit(() => _repository.login(email: email, password: password));
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _submit(
      () => _repository.register(name: name, email: email, password: password),
    );
  }

  Future<void> loginWithGoogle() => _submit(_repository.loginWithGoogle);

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void clearError() {
    if (state.error != null) emit(state.copyWith(clearError: true));
  }

  Future<void> _submit(Future<AppUser> Function() action) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final user = await action();
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on AppException catch (exception) {
      if (exception.error == AppError.signInCancelled) {
        emit(state.copyWith(isSubmitting: false, clearError: true));
        return;
      }
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isSubmitting: false,
          error: exception.error,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isSubmitting: false,
          error: AppError.unknown,
        ),
      );
    }
  }
}
