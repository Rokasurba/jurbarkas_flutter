import 'package:dio/dio.dart';
import 'package:frontend/core/api/auth_interceptor.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/storage/secure_storage.dart';

export 'auth_interceptor.dart' show OnAuthenticationFailed;

class ApiClient {
  ApiClient({
    required SecureStorage secureStorage,
    OnAuthenticationFailed? onAuthenticationFailed,
    Dio? dio,
  })  : _secureStorage = secureStorage,
        _dio = dio ?? Dio() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    _dio.interceptors.add(AuthInterceptor(
      secureStorage: _secureStorage,
      dio: _dio,
      onAuthenticationFailed: onAuthenticationFailed,
    ));
  }

  final Dio _dio;
  final SecureStorage _secureStorage;

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
