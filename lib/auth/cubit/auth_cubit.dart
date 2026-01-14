import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/auth/data/auth_repository.dart';
import 'package:frontend/auth/data/models/user_model.dart';

part 'auth_state.dart';
part 'auth_cubit.freezed.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.initial());

  final AuthRepository _authRepository;

  Future<void> checkAuthStatus() async {
    emit(const AuthState.loading());

    final hasToken = await _authRepository.hasToken();
    if (!hasToken) {
      emit(const AuthState.unauthenticated());
      return;
    }

    try {
      final user = await _authRepository.getCurrentUser();
      emit(AuthState.authenticated(user));
    } on AuthException {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthState.loading());

    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );
      emit(AuthState.authenticated(user));
    } on AuthException catch (e) {
      emit(AuthState.error(e.message));
    }
  }

  Future<void> logout() async {
    emit(const AuthState.loading());

    try {
      await _authRepository.logout();
    } finally {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> refreshToken() async {
    try {
      final user = await _authRepository.refreshToken();
      emit(AuthState.authenticated(user));
    } on AuthException {
      emit(const AuthState.unauthenticated());
    }
  }

  void clearError() {
    if (state is AuthError) {
      emit(const AuthState.unauthenticated());
    }
  }
}
