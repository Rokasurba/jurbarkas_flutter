import 'package:dio/dio.dart';
import 'package:frontend/auth/data/models/auth_response.dart';
import 'package:frontend/auth/data/models/login_request.dart';
import 'package:frontend/auth/data/models/refresh_token_request.dart';
import 'package:frontend/auth/data/models/user_model.dart';
import 'package:frontend/core/api/api_client.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/data/api_response.dart';
import 'package:frontend/core/storage/secure_storage.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required SecureStorage secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage;

  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  Future<ApiResponse<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest(email: email, password: password);

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => AuthResponse.fromJson(json! as Map<String, dynamic>),
      );

      return apiResponse.when(
        success: (authResponse, message) async {
          await _secureStorage.saveTokens(
            accessToken: authResponse.accessToken,
            refreshToken: authResponse.refreshToken,
          );
          return ApiResponse.success(data: authResponse.user, message: message);
        },
        error: (message, errors) => ApiResponse.error(
          message: message,
          errors: errors,
        ),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: _extractErrorMessage(e));
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post<void>(ApiConstants.logout);
    } finally {
      await _secureStorage.deleteTokens();
    }
  }

  Future<ApiResponse<User>> getCurrentUser() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.user,
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => User.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _secureStorage.deleteTokens();
      }
      return ApiResponse.error(message: _extractErrorMessage(e));
    }
  }

  Future<ApiResponse<User>> refreshToken() async {
    try {
      final currentRefreshToken = await _secureStorage.getRefreshToken();
      if (currentRefreshToken == null) {
        return const ApiResponse.error(message: 'No refresh token available');
      }

      final request = RefreshTokenRequest(refreshToken: currentRefreshToken);

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.refresh,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => AuthResponse.fromJson(json! as Map<String, dynamic>),
      );

      return apiResponse.when(
        success: (authResponse, message) async {
          await _secureStorage.saveTokens(
            accessToken: authResponse.accessToken,
            refreshToken: authResponse.refreshToken,
          );
          return ApiResponse.success(data: authResponse.user, message: message);
        },
        error: (message, errors) async {
          await _secureStorage.deleteTokens();
          return ApiResponse.error(message: message, errors: errors);
        },
      );
    } on DioException catch (e) {
      await _secureStorage.deleteTokens();
      return ApiResponse.error(message: _extractErrorMessage(e));
    }
  }

  Future<bool> hasToken() async {
    return _secureStorage.hasToken();
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? 'Network error';
    }
    return 'Network error';
  }
}
