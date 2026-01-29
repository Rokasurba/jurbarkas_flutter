import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/survey/data/models/survey_option.dart';

part 'survey_question.freezed.dart';
part 'survey_question.g.dart';

@freezed
class SurveyQuestion with _$SurveyQuestion {
  const factory SurveyQuestion({
    required int id,
    @JsonKey(name: 'question_text') required String questionText,
    @JsonKey(name: 'question_type') required String questionType,
    @JsonKey(name: 'is_required') required bool isRequired,
    @JsonKey(name: 'order_index') required int orderIndex,
    required List<SurveyOption> options,
  }) = _SurveyQuestion;

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) =>
      _$SurveyQuestionFromJson(json);
}
