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

  Future<User> login({
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
        success: (authResponse, _) async {
          await _secureStorage.saveTokens(
            accessToken: authResponse.accessToken,
            refreshToken: authResponse.refreshToken,
          );
          return authResponse.user;
        },
        error: (message, _) => throw AuthException(message),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post<void>(ApiConstants.logout);
    } finally {
      await _secureStorage.deleteTokens();
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.user,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => User.fromJson(json! as Map<String, dynamic>),
      );

      return apiResponse.when(
        success: (user, _) => user,
        error: (message, _) => throw AuthException(message),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _secureStorage.deleteTokens();
        throw AuthException('Session expired');
      }
      throw _handleDioError(e);
    }
  }

  Future<User> refreshToken() async {
    try {
      final currentRefreshToken = await _secureStorage.getRefreshToken();
      if (currentRefreshToken == null) {
        throw AuthException('No refresh token available');
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
        success: (authResponse, _) async {
          await _secureStorage.saveTokens(
            accessToken: authResponse.accessToken,
            refreshToken: authResponse.refreshToken,
          );
          return authResponse.user;
        },
        error: (message, _) {
          _secureStorage.deleteTokens();
          throw AuthException(message);
        },
      );
    } on DioException catch (e) {
      await _secureStorage.deleteTokens();
      throw _handleDioError(e, fallbackMessage: 'Session expired');
    }
  }

  Future<bool> hasToken() async {
    return _secureStorage.hasToken();
  }

  AuthException _handleDioError(
    DioException e, {
    String fallbackMessage = 'Network error',
  }) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] as String?;
      if (message != null) {
        return AuthException(message);
      }
    }
    return AuthException(fallbackMessage);
  }
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
