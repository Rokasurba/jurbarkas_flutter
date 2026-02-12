import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_survey_request.freezed.dart';
part 'create_survey_request.g.dart';

@freezed
class CreateSurveyRequest with _$CreateSurveyRequest {
  @JsonSerializable(explicitToJson: true)
  const factory CreateSurveyRequest({
    required String title,
    required List<CreateQuestionRequest> questions,
    String? description,
  }) = _CreateSurveyRequest;

  factory CreateSurveyRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSurveyRequestFromJson(json);
}

@freezed
class CreateQuestionRequest with _$CreateQuestionRequest {
  @JsonSerializable(explicitToJson: true)
  const factory CreateQuestionRequest({
    @JsonKey(name: 'question_text') required String questionText,
    @JsonKey(name: 'question_type') required String questionType,
    @JsonKey(name: 'is_required') required bool isRequired,
    @JsonKey(name: 'order_index') required int orderIndex,
    required List<CreateOptionRequest> options,
  }) = _CreateQuestionRequest;

  factory CreateQuestionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateQuestionRequestFromJson(json);
}

@freezed
class CreateOptionRequest with _$CreateOptionRequest {
  const factory CreateOptionRequest({
    @JsonKey(name: 'option_text') required String optionText,
    @JsonKey(name: 'order_index') required int orderIndex,
  }) = _CreateOptionRequest;

  factory CreateOptionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateOptionRequestFromJson(json);
}
