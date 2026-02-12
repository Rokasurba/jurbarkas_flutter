import 'package:dio/dio.dart';
import 'package:frontend/core/api/auth_event_controller.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/data/api_response.dart';
import 'package:frontend/core/data/models/refresh_token_request.dart';
import 'package:frontend/core/data/models/token_response.dart';
import 'package:frontend/core/storage/secure_storage.dart';

/// Interceptor that handles authentication token management.
/// - Adds Bearer token to requests
/// - Automatically refreshes token on 401 errors
/// - Retries failed requests with new token
/// - Emits event via AuthEventController when authentication fails completely
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.secureStorage,
    required this.dio,
  });

  final SecureStorage secureStorage;
  final Dio dio;

  /// Separate Dio instance for refresh calls to avoid QueuedInterceptor
  /// deadlock when the refresh request also returns 401.
  Dio? _refreshDio;

  bool _isRefreshing = false;

  Dio get _getRefreshDio {
    return _refreshDio ??= Dio(BaseOptions(
      baseUrl: dio.options.baseUrl,
      headers: dio.options.headers,
    ));
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Skip refresh for auth endpoints
    final path = err.requestOptions.path;
    if (_isAuthEndpoint(path)) {
      return handler.next(err);
    }

    // Try to refresh token
    final refreshed = await _tryRefreshToken();
    if (!refreshed) {
      await _handleAuthenticationFailure();
      return handler.next(err);
    }

    // Retry original request with new token
    try {
      final response = await _retryRequest(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh');
  }

  Future<bool> _tryRefreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;

    try {
      final refreshToken = await secureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final request = RefreshTokenRequest(refreshToken: refreshToken);
      final response = await _getRefreshDio.post<Map<String, dynamic>>(
        ApiConstants.refresh,
        data: request.toJson(),
      );

      if (response.data == null) return false;

      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => TokenResponse.fromJson(json! as Map<String, dynamic>),
      );

      return apiResponse.when(
        success: (tokenResponse, _) async {
          await secureStorage.saveTokens(
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken,
          );
          return true;
        },
        error: (_, _) => false,
      );
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions options) async {
    final token = await secureStorage.getAccessToken();
    options.headers['Authorization'] = 'Bearer $token';
    return dio.fetch(options);
  }

  Future<void> _handleAuthenticationFailure() async {
    await secureStorage.deleteTokens();
    AuthEventController.instance.emitAuthenticationFailed();
  }
}
