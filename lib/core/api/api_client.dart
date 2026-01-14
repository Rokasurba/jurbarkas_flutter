import 'package:dio/dio.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/storage/secure_storage.dart';

/// Callback when authentication fails and user needs to be logged out.
typedef OnAuthenticationFailed = void Function();

class ApiClient {
  ApiClient({
    required SecureStorage secureStorage,
    OnAuthenticationFailed? onAuthenticationFailed,
    Dio? dio,
  })  : _secureStorage = secureStorage,
        _onAuthenticationFailed = onAuthenticationFailed,
        _dio = dio ?? Dio() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    _dio.interceptors.add(_AuthInterceptor(
      secureStorage: _secureStorage,
      dio: _dio,
      onAuthenticationFailed: _onAuthenticationFailed,
    ));
  }

  final Dio _dio;
  final SecureStorage _secureStorage;
  final OnAuthenticationFailed? _onAuthenticationFailed;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
  }) async {
    return _dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
  }) async {
    return _dio.put<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path) async {
    return _dio.delete<T>(path);
  }
}

class _AuthInterceptor extends QueuedInterceptor {
  _AuthInterceptor({
    required this.secureStorage,
    required this.dio,
    this.onAuthenticationFailed,
  });

  final SecureStorage secureStorage;
  final Dio dio;
  final OnAuthenticationFailed? onAuthenticationFailed;

  bool _isRefreshing = false;

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

      final response = await dio.post<Map<String, dynamic>>(
        ApiConstants.refresh,
        data: {'refresh_token': refreshToken},
      );

      final data = response.data;
      if (data == null || data['success'] != true) return false;

      final responseData = data['data'] as Map<String, dynamic>?;
      if (responseData == null) return false;

      final newAccessToken = responseData['access_token'] as String?;
      final newRefreshToken = responseData['refresh_token'] as String?;

      if (newAccessToken == null || newRefreshToken == null) return false;

      await secureStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      return true;
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
    onAuthenticationFailed?.call();
  }
}
