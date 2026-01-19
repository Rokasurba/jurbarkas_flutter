import 'package:dio/dio.dart';
import 'package:frontend/auth/data/models/auth_response.dart';
import 'package:frontend/auth/data/models/login_request.dart';
import 'package:frontend/auth/data/models/register_request.dart';
import 'package:frontend/auth/data/models/user_model.dart';
import 'package:frontend/core/core.dart';

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
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  Future<ApiResponse<User>> register({
    required String name,
    required String surname,
    required String email,
    required String password,
    required String passwordConfirmation,
    required bool consent,
    String? phone,
    String? dateOfBirth,
  }) async {
    try {
      final request = RegisterRequest(
        name: name,
        surname: surname,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        consent: consent,
        phone: phone,
        dateOfBirth: dateOfBirth,
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.register,
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
      return ApiResponse.error(message: extractDioErrorMessage(e));
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
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  Future<bool> hasToken() async {
    return _secureStorage.hasToken();
  }
}
