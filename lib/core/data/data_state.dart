import 'package:freezed_annotation/freezed_annotation.dart';

part 'data_state.freezed.dart';

/// A sealed class representing the state of data operations.
/// Use this for API responses and async operations that can succeed or fail.
@freezed
sealed class DataState<T> with _$DataState<T> {
  const DataState._();

  /// Represents a successful data operation with the resulting data.
  const factory DataState.success(T data) = DataSuccess<T>;

  /// Represents a failed data operation with an error message.
  const factory DataState.error(String message) = DataError<T>;

  /// Returns true if this is a success state.
  bool get isSuccess => this is DataSuccess<T>;

  /// Returns true if this is an error state.
  bool get isError => this is DataError<T>;

  /// Returns the data if success, null otherwise.
  T? get dataOrNull => whenOrNull(success: (data) => data);

  /// Returns the error message if error, null otherwise.
  String? get errorOrNull => whenOrNull(error: (message) => message);

  /// Gets the data or throws an exception if error.
  T get requireData => when(
        success: (data) => data,
        error: (message) => throw StateError('DataState is error: $message'),
      );
}
