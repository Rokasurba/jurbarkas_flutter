part of 'password_reset_cubit.dart';

@freezed
class PasswordResetState with _$PasswordResetState {
  const PasswordResetState._();

  const factory PasswordResetState.initial() = PasswordResetInitial;
  const factory PasswordResetState.loading() = PasswordResetLoading;
  const factory PasswordResetState.otpSent(String message) = PasswordResetOtpSent;
  const factory PasswordResetState.otpVerified() = PasswordResetOtpVerified;
  const factory PasswordResetState.success(String message) = PasswordResetSuccess;
  const factory PasswordResetState.error(String message) = PasswordResetError;

  bool get isLoading => this is PasswordResetLoading;
  bool get isOtpSent => this is PasswordResetOtpSent;
  bool get isOtpVerified => this is PasswordResetOtpVerified;
  bool get isSuccess => this is PasswordResetSuccess;
  bool get isError => this is PasswordResetError;

  String? get errorMessage => whenOrNull(error: (message) => message);
  String? get successMessage => whenOrNull(success: (message) => message);
}
