import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/password_reset/data/password_reset_repository.dart';

part 'password_reset_state.dart';
part 'password_reset_cubit.freezed.dart';

class PasswordResetCubit extends Cubit<PasswordResetState> {
  PasswordResetCubit({required PasswordResetRepository passwordResetRepository})
      : _passwordResetRepository = passwordResetRepository,
        super(const PasswordResetState.initial());

  final PasswordResetRepository _passwordResetRepository;

  // Email is kept in memory for display purposes only (not sensitive)
  String _email = '';

  String get email => _email;

  Future<void> sendOtp({required String email}) async {
    emit(const PasswordResetState.loading());
    _email = email;

    final response =
        await _passwordResetRepository.forgotPassword(email: email);

    response.when(
      success: (_, message) => emit(PasswordResetState.otpSent(message ?? '')),
      error: (message, _) => emit(PasswordResetState.error(message)),
    );
  }

  Future<void> verifyOtp({required String otp}) async {
    emit(const PasswordResetState.loading());

    final response = await _passwordResetRepository.verifyOtp(
      email: _email,
      otp: otp,
    );

    response.when(
      success: (_, __) => emit(const PasswordResetState.otpVerified()),
      error: (message, _) => emit(PasswordResetState.error(message)),
    );
  }

  Future<void> resetPassword({
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(const PasswordResetState.loading());

    // Get stored data from secure storage
    final storedEmail = await _passwordResetRepository.getStoredEmail();
    final storedToken = await _passwordResetRepository.getStoredResetToken();

    if (storedEmail == null || storedToken == null) {
      emit(const PasswordResetState.error('Sesija pasibaigė'));
      return;
    }

    final response = await _passwordResetRepository.resetPassword(
      email: storedEmail,
      resetToken: storedToken,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    response.when(
      success: (_, message) =>
          emit(PasswordResetState.success(message ?? '')),
      error: (message, _) => emit(PasswordResetState.error(message)),
    );
  }

  Future<void> clearError() async {
    if (state is PasswordResetError) {
      // Check secure storage to determine flow progress
      final storedToken = await _passwordResetRepository.getStoredResetToken();
      final storedEmail = await _passwordResetRepository.getStoredEmail();

      if (storedToken != null) {
        emit(const PasswordResetState.otpVerified());
      } else if (storedEmail != null) {
        emit(const PasswordResetState.otpSent(''));
      } else {
        emit(const PasswordResetState.initial());
      }
    }
  }

  Future<void> reset() async {
    _email = '';
    await _passwordResetRepository.clearStoredData();
    emit(const PasswordResetState.initial());
  }
}
