import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/survey/data/models/completed_survey.dart';
import 'package:frontend/survey/data/models/survey_answer.dart';
import 'package:frontend/survey/data/models/survey_for_completion.dart';

part 'survey_completion_state.freezed.dart';

@freezed
sealed class SurveyCompletionState with _$SurveyCompletionState {
  const factory SurveyCompletionState.initial() = SurveyCompletionInitial;
  const factory SurveyCompletionState.loading() = SurveyCompletionLoading;
  const factory SurveyCompletionState.loaded({
    required SurveyForCompletion survey,
    required int currentIndex,
    required Map<int, SurveyAnswer> answers,
  }) = SurveyCompletionLoaded;
  const factory SurveyCompletionState.submitting({
    required SurveyForCompletion survey,
    required int currentIndex,
    required Map<int, SurveyAnswer> answers,
  }) = SurveyCompletionSubmitting;
  const factory SurveyCompletionState.completed(String message) =
      SurveyCompletionCompleted;
  const factory SurveyCompletionState.viewingCompleted(
    CompletedSurvey completedSurvey,
  ) = SurveyCompletionViewingCompleted;
  const factory SurveyCompletionState.error(String message) =
      SurveyCompletionError;
}
