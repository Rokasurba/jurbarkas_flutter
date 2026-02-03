import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_log.freezed.dart';
part 'activity_log.g.dart';

/// Represents a user who caused an activity log event.
@freezed
class ActivityLogCauser with _$ActivityLogCauser {
  const factory ActivityLogCauser({
    required int id,
    required String name,
    required String role,
  }) = _ActivityLogCauser;

  factory ActivityLogCauser.fromJson(Map<String, dynamic> json) =>
      _$ActivityLogCauserFromJson(json);
}

/// Represents a single activity log entry from the spatie/laravel-activitylog.
@freezed
class ActivityLog with _$ActivityLog {
  const factory ActivityLog({
    required int id,
    required String description,
    String? event,
    @JsonKey(name: 'subject_type') String? subjectType,
    @JsonKey(name: 'subject_id') int? subjectId,
    ActivityLogCauser? causer,
    @Default({}) Map<String, dynamic> properties,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ActivityLog;

  factory ActivityLog.fromJson(Map<String, dynamic> json) =>
      _$ActivityLogFromJson(json);
}
