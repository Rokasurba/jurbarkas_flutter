import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/survey/data/models/survey_question.dart';

part 'survey_details.freezed.dart';
part 'survey_details.g.dart';

/// Full survey details including questions and options.
/// Used for editing surveys and viewing survey structure.
@freezed
class SurveyDetails with _$SurveyDetails {
  const factory SurveyDetails({
    required int id,
    required String title,
    @JsonKey(name: 'created_by') required int createdBy,
    @JsonKey(name: 'creator_name') required String creatorName,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'question_count') required int questionCount,
    @JsonKey(name: 'assignment_count') required int assignmentCount,
    @JsonKey(name: 'created_at') required String createdAt,
    String? description,
    @Default([]) List<SurveyQuestion> questions,
  }) = _SurveyDetails;

  factory SurveyDetails.fromJson(Map<String, dynamic> json) =>
      _$SurveyDetailsFromJson(json);
}
