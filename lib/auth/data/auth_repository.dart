import 'package:dio/dio.dart';
import 'package:frontend/auth/data/models/auth_response.dart';
import 'package:frontend/auth/data/models/login_request.dart';
import 'package:frontend/auth/data/models/user_model.dart';
import 'package:frontend/core/api/api_client.dart';
import 'package:frontend/core/constants/api_constants.dart';
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

      final data = response.data!;
      if (data['success'] != true) {
        throw AuthException(data['message'] as String? ?? 'Login failed');
      }

      final authResponse = AuthResponse.fromJson(
        data['data'] as Map<String, dynamic>,
      );

      await _secureStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return authResponse.user;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String?;
      throw AuthException(message ?? 'Network error');
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

      final data = response.data!;
      if (data['success'] != true) {
        throw AuthException('Failed to get user');
      }

      return User.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _secureStorage.deleteTokens();
        throw AuthException('Session expired');
      }
      throw AuthException(
        e.response?.data?['message'] as String? ?? 'Network error',
      );
    }
  }

  Future<User> refreshToken() async {
    try {
      final currentRefreshToken = await _secureStorage.getRefreshToken();
      if (currentRefreshToken == null) {
        throw AuthException('No refresh token available');
      }

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.refresh,
        data: {'refresh_token': currentRefreshToken},
      );

      final data = response.data!;
      if (data['success'] != true) {
        throw AuthException('Failed to refresh token');
      }

      final authResponse = AuthResponse.fromJson(
        data['data'] as Map<String, dynamic>,
      );

      await _secureStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return authResponse.user;
    } on DioException catch (e) {
      await _secureStorage.deleteTokens();
      throw AuthException(
        e.response?.data?['message'] as String? ?? 'Session expired',
      );
    }
  }

  Future<bool> hasToken() async {
    return _secureStorage.hasToken();
  }
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
