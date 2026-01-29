import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/survey/data/models/assigned_survey.dart';

part 'survey_list_state.freezed.dart';

@freezed
sealed class SurveyListState with _$SurveyListState {
  const factory SurveyListState.initial() = SurveyListInitial;
  const factory SurveyListState.loading() = SurveyListLoading;
  const factory SurveyListState.loaded(List<AssignedSurvey> surveys) =
      SurveyListLoaded;
  const factory SurveyListState.error(String message) = SurveyListError;
}
