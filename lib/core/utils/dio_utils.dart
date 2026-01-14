import 'package:dio/dio.dart';

/// Extracts error message from DioException response.
/// Falls back to [fallback] if no message found.
String extractDioErrorMessage(
  DioException e, {
  String fallback = 'Network error',
}) {
  final data = e.response?.data;
  if (data is Map<String, dynamic>) {
    return data['message'] as String? ?? fallback;
  }
  return fallback;
}
