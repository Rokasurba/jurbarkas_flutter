import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/core/data/data_state.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

/// Represents the standard API response format from the backend.
/// The backend returns: { success: bool, data: T?, message: string?, errors: [] }
@Freezed(genericArgumentFactories: true)
class ApiResponse<T> with _$ApiResponse<T> {
  const ApiResponse._();

  const factory ApiResponse({
    required bool success,
    T? data,
    String? message,
    @Default({}) Map<String, List<String>> errors,
  }) = _ApiResponse<T>;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  /// Converts this API response to a DataState for easier handling.
  DataState<T> toDataState() {
    if (success && data != null) {
      return DataState.success(data as T);
    }
    return DataState.error(message ?? 'Unknown error');
  }

  /// Returns the first error message from the errors map, or the message field.
  String get firstError {
    if (errors.isNotEmpty) {
      final firstKey = errors.keys.first;
      final firstErrors = errors[firstKey];
      if (firstErrors != null && firstErrors.isNotEmpty) {
        return firstErrors.first;
      }
    }
    return message ?? 'Unknown error';
  }
}
