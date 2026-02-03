import 'package:dio/dio.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/password_reset/data/models/forgot_password_request.dart';
import 'package:frontend/password_reset/data/models/reset_password_request.dart';
import 'package:frontend/password_reset/data/models/verify_otp_request.dart';
import 'package:frontend/password_reset/data/models/verify_otp_response.dart';

class PasswordResetRepository {
  PasswordResetRepository({
    required ApiClient apiClient,
    required SecureStorage secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage;

  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  Future<ApiResponse<void>> forgotPassword({
    required String email,
  }) async {
    try {
      final request = ForgotPasswordRequest(email: email);

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.forgotPassword,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (_) {},
      );

      // Save email to secure storage on success
      await apiResponse.whenOrNull(
        success: (data, message) async {
          await _secureStorage.savePasswordResetData(email: email);
        },
      );

      return apiResponse;
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  Future<ApiResponse<VerifyOtpResponse>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final request = VerifyOtpRequest(email: email, otp: otp);

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.verifyOtp,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => VerifyOtpResponse.fromJson(json! as Map<String, dynamic>),
      );

      // Save reset token to secure storage on success
      await apiResponse.whenOrNull(
        success: (data, _) async {
          await _secureStorage.savePasswordResetData(
            email: email,
            resetToken: data.resetToken,
          );
        },
      );

      return apiResponse;
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  Future<ApiResponse<void>> resetPassword({
    required String email,
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final request = ResetPasswordRequest(
        email: email,
        resetToken: resetToken,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.resetPassword,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (_) {},
      );

      // Clear secure storage on success
      await apiResponse.whenOrNull(
        success: (data, message) async {
          await _secureStorage.clearPasswordResetData();
        },
      );

      return apiResponse;
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  /// Get stored email from secure storage
  Future<String?> getStoredEmail() => _secureStorage.getResetEmail();

  /// Get stored reset token from secure storage
  Future<String?> getStoredResetToken() => _secureStorage.getResetToken();

  /// Clear all password reset data from secure storage
  Future<void> clearStoredData() => _secureStorage.clearPasswordResetData();
}
