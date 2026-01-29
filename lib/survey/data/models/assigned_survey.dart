import 'package:freezed_annotation/freezed_annotation.dart';

part 'assigned_survey.freezed.dart';
part 'assigned_survey.g.dart';

@freezed
class AssignedSurvey with _$AssignedSurvey {
  const factory AssignedSurvey({
    required int id,
    @JsonKey(name: 'survey_id') required int surveyId,
    @JsonKey(name: 'survey_title') required String surveyTitle,
    @JsonKey(name: 'question_count') required int questionCount,
    @JsonKey(name: 'assigned_at') required String assignedAt,
    @JsonKey(name: 'is_completed') required bool isCompleted,
    @JsonKey(name: 'survey_description') String? surveyDescription,
    @JsonKey(name: 'completed_at') String? completedAt,
  }) = _AssignedSurvey;

  factory AssignedSurvey.fromJson(Map<String, dynamic> json) =>
      _$AssignedSurveyFromJson(json);
}
