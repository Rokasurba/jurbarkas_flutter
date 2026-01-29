import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/survey/data/models/survey.dart';

part 'doctor_survey_list_state.freezed.dart';

@freezed
sealed class DoctorSurveyListState with _$DoctorSurveyListState {
  const factory DoctorSurveyListState.initial() = DoctorSurveyListInitial;
  const factory DoctorSurveyListState.loading() = DoctorSurveyListLoading;
  const factory DoctorSurveyListState.loaded(List<Survey> surveys) =
      DoctorSurveyListLoaded;
  const factory DoctorSurveyListState.error(String message) =
      DoctorSurveyListError;
}
