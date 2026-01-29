import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/survey/data/models/aggregated_question.dart';

part 'aggregated_survey_results.freezed.dart';
part 'aggregated_survey_results.g.dart';

@freezed
class AggregatedSurveyResults with _$AggregatedSurveyResults {
  const factory AggregatedSurveyResults({
    @JsonKey(name: 'survey_id') required int surveyId,
    @JsonKey(name: 'survey_title') required String surveyTitle,
    @JsonKey(name: 'total_assigned') required int totalAssigned,
    @JsonKey(name: 'total_completed') required int totalCompleted,
    @JsonKey(name: 'completion_rate') required double completionRate,
    required List<AggregatedQuestion> questions,
    @JsonKey(name: 'survey_description') String? surveyDescription,
  }) = _AggregatedSurveyResults;

  factory AggregatedSurveyResults.fromJson(Map<String, dynamic> json) =>
      _$AggregatedSurveyResultsFromJson(json);
}
