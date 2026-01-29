import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/survey/data/models/survey_question.dart';

part 'survey_for_completion.freezed.dart';
part 'survey_for_completion.g.dart';

@freezed
class SurveyForCompletion with _$SurveyForCompletion {
  const factory SurveyForCompletion({
    @JsonKey(name: 'assignment_id') required int assignmentId,
    @JsonKey(name: 'survey_id') required int surveyId,
    required String title,
    @JsonKey(name: 'is_completed') required bool isCompleted,
    required List<SurveyQuestion> questions,
    String? description,
  }) = _SurveyForCompletion;

  factory SurveyForCompletion.fromJson(Map<String, dynamic> json) =>
      _$SurveyForCompletionFromJson(json);
}
