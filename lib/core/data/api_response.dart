import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';

/// Represents the standard API response format from the backend.
/// The backend returns: { success: bool, data: T?, message: string?, errors: {} }
///
/// Usage:
/// ```dart
/// final response = ApiResponse.fromJson(json, (data) => User.fromJson(data));
/// response.when(
///   success: (data, message) => print('Got user: ${data.name}'),
///   error: (message, errors) => print('Error: $message'),
/// );
/// ```
@freezed
sealed class ApiResponse<T> with _$ApiResponse<T> {
  const ApiResponse._();

  /// Successful API response with data.
  const factory ApiResponse.success({
    required T data,
    String? message,
  }) = ApiSuccess<T>;

  /// Failed API response with error message and optional field errors.
  const factory ApiResponse.error({
    required String message,
    @Default({}) Map<String, List<String>> errors,
  }) = ApiError<T>;

  /// Parses JSON response from backend into typed ApiResponse.
  ///
  /// [json] - The raw JSON map from the API
  /// [fromJsonT] - Function to parse the `data` field into type T
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final success = json['success'] as bool? ?? false;

    if (success) {
      return ApiResponse.success(
        data: fromJsonT(json['data']),
        message: json['message'] as String?,
      );
    }

    return ApiResponse.error(
      message: json['message'] as String? ?? 'Unknown error',
      errors: _parseErrors(json['errors']),
    );
  }

  /// Helper to parse errors field which can be Map or List.
  static Map<String, List<String>> _parseErrors(dynamic errors) {
    if (errors == null) return {};

    if (errors is Map) {
      return errors.map((key, value) {
        if (value is List) {
          return MapEntry(
            key.toString(),
            value.map((e) => e.toString()).toList(),
          );
        }
        return MapEntry(key.toString(), [value.toString()]);
      });
    }

    return {};
  }

  /// Returns true if this is a success response.
  bool get isSuccess => this is ApiSuccess<T>;

  /// Returns true if this is an error response.
  bool get isError => this is ApiError<T>;

  /// Gets the data if success, null otherwise.
  T? get dataOrNull => whenOrNull(success: (data, _) => data);

  /// Gets the error message if error, null otherwise.
  String? get errorOrNull => whenOrNull(error: (message, _) => message);

  /// Gets the first validation error from errors map, or the main message.
  String get firstError => when(
    success: (_, message) => message ?? '',
    error: (message, errors) {
      if (errors.isNotEmpty) {
        final firstKey = errors.keys.first;
        final firstErrors = errors[firstKey];
        if (firstErrors != null && firstErrors.isNotEmpty) {
          return firstErrors.first;
        }
      }
      return message;
    },
  );
}
