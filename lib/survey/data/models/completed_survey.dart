import 'package:freezed_annotation/freezed_annotation.dart';

part 'completed_survey.freezed.dart';
part 'completed_survey.g.dart';

@freezed
class CompletedSurveyAnswer with _$CompletedSurveyAnswer {
  const factory CompletedSurveyAnswer({
    @JsonKey(name: 'selected_option_id') int? selectedOptionId,
    @JsonKey(name: 'selected_option_text') String? selectedOptionText,
    @JsonKey(name: 'selected_option_ids') List<int>? selectedOptionIds,
    @JsonKey(name: 'selected_option_texts') List<String>? selectedOptionTexts,
    @JsonKey(name: 'text_answer') String? textAnswer,
  }) = _CompletedSurveyAnswer;

  factory CompletedSurveyAnswer.fromJson(Map<String, dynamic> json) =>
      _$CompletedSurveyAnswerFromJson(json);
}

@freezed
class CompletedSurveyQuestion with _$CompletedSurveyQuestion {
  const factory CompletedSurveyQuestion({
    @JsonKey(name: 'question_id') required int questionId,
    @JsonKey(name: 'question_text') required String questionText,
    @JsonKey(name: 'question_type') required String questionType,
    required CompletedSurveyAnswer answer,
  }) = _CompletedSurveyQuestion;

  factory CompletedSurveyQuestion.fromJson(Map<String, dynamic> json) =>
      _$CompletedSurveyQuestionFromJson(json);
}

@freezed
class CompletedSurvey with _$CompletedSurvey {
  const factory CompletedSurvey({
    @JsonKey(name: 'assignment_id') required int assignmentId,
    @JsonKey(name: 'survey_id') required int surveyId,
    required String title,
    @JsonKey(name: 'completed_at') required String completedAt,
    required List<CompletedSurveyQuestion> answers,
    String? description,
  }) = _CompletedSurvey;

  factory CompletedSurvey.fromJson(Map<String, dynamic> json) =>
      _$CompletedSurveyFromJson(json);
}
