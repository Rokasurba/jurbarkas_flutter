import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/survey/data/models/assigned_survey.dart';

part 'patient_surveys_state.freezed.dart';

@freezed
sealed class PatientSurveysState with _$PatientSurveysState {
  const factory PatientSurveysState.initial() = PatientSurveysInitial;
  const factory PatientSurveysState.loading() = PatientSurveysLoading;
  const factory PatientSurveysState.loaded(List<AssignedSurvey> surveys) =
      PatientSurveysLoaded;
  const factory PatientSurveysState.error(String message) = PatientSurveysError;
}
