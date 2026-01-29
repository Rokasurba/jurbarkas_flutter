import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/survey/data/models/aggregated_option.dart';

part 'aggregated_question.freezed.dart';
part 'aggregated_question.g.dart';

@freezed
class AggregatedQuestion with _$AggregatedQuestion {
  const factory AggregatedQuestion({
    @JsonKey(name: 'question_id') required int questionId,
    @JsonKey(name: 'question_text') required String questionText,
    @JsonKey(name: 'question_type') required String questionType,
    @JsonKey(name: 'is_required') required bool isRequired,
    @JsonKey(name: 'total_responses') required int totalResponses,
    List<AggregatedOption>? options,
    @JsonKey(name: 'text_responses') List<String>? textResponses,
  }) = _AggregatedQuestion;

  factory AggregatedQuestion.fromJson(Map<String, dynamic> json) =>
      _$AggregatedQuestionFromJson(json);
}
