import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/survey/data/models/doctor_survey_results.dart';

part 'doctor_survey_results_state.freezed.dart';

@freezed
sealed class DoctorSurveyResultsState with _$DoctorSurveyResultsState {
  const factory DoctorSurveyResultsState.initial() = DoctorSurveyResultsInitial;
  const factory DoctorSurveyResultsState.loading() = DoctorSurveyResultsLoading;
  const factory DoctorSurveyResultsState.loaded(DoctorSurveyResults results) =
      DoctorSurveyResultsLoaded;
  const factory DoctorSurveyResultsState.empty() = DoctorSurveyResultsEmpty;
  const factory DoctorSurveyResultsState.error(String message) =
      DoctorSurveyResultsError;
}
