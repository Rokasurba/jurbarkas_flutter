import 'package:freezed_annotation/freezed_annotation.dart';

part 'survey_answer.freezed.dart';
part 'survey_answer.g.dart';

@freezed
class SurveyAnswer with _$SurveyAnswer {
  const factory SurveyAnswer({
    @JsonKey(name: 'question_id') required int questionId,
    @JsonKey(name: 'selected_option_id') int? selectedOptionId,
    @JsonKey(name: 'selected_option_ids') List<int>? selectedOptionIds,
    @JsonKey(name: 'text_answer') String? textAnswer,
  }) = _SurveyAnswer;

  factory SurveyAnswer.fromJson(Map<String, dynamic> json) =>
      _$SurveyAnswerFromJson(json);
}

@freezed
class SubmitAnswersRequest with _$SubmitAnswersRequest {
  const factory SubmitAnswersRequest({
    required List<SurveyAnswer> answers,
  }) = _SubmitAnswersRequest;

  factory SubmitAnswersRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitAnswersRequestFromJson(json);
}
