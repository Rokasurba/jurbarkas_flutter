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

    final response = await _authRepository.getCurrentUser();
    response.when(
      success: (user, _) => emit(AuthState.authenticated(user)),
      error: (_, __) => emit(const AuthState.unauthenticated()),
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthState.loading());

    final response = await _authRepository.login(
      email: email,
      password: password,
    );

    response.when(
      success: (user, _) => emit(AuthState.authenticated(user)),
      error: (message, _) => emit(AuthState.error(message)),
    );
  }

  Future<void> logout() async {
    emit(const AuthState.loading());
    await _authRepository.logout();
    emit(const AuthState.unauthenticated());
  }

  Future<void> refreshToken() async {
    final response = await _authRepository.refreshToken();
    response.when(
      success: (user, _) => emit(AuthState.authenticated(user)),
      error: (_, __) => emit(const AuthState.unauthenticated()),
    );
  }

  void clearError() {
    if (state is AuthError) {
      emit(const AuthState.unauthenticated());
    }
  }
}
