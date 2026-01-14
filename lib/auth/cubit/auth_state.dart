part of 'auth_cubit.dart';

@freezed
class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated(User user) = AuthAuthenticated;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
  const factory AuthState.error(String message) = AuthError;

  bool get isAuthenticated => this is AuthAuthenticated;
  bool get isLoading => this is AuthLoading;

  User? get user => whenOrNull(authenticated: (user) => user);
  String? get errorMessage => whenOrNull(error: (message) => message);
}
