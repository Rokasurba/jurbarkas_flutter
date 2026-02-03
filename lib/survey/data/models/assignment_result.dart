import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignment_result.freezed.dart';
part 'assignment_result.g.dart';

/// Result of assigning a survey to patients.
@freezed
class AssignmentResult with _$AssignmentResult {
  const factory AssignmentResult({
    @JsonKey(name: 'assigned_count') required int assignedCount,
    @JsonKey(name: 'skipped_count') required int skippedCount,
  }) = _AssignmentResult;

  factory AssignmentResult.fromJson(Map<String, dynamic> json) =>
      _$AssignmentResultFromJson(json);
}
