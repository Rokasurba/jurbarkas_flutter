import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/survey/cubit/patient_surveys_state.dart';
import 'package:frontend/survey/data/survey_repository.dart';

class PatientSurveysCubit extends Cubit<PatientSurveysState> {
  PatientSurveysCubit({required SurveyRepository surveyRepository})
      : _surveyRepository = surveyRepository,
        super(const PatientSurveysState.initial());

  final SurveyRepository _surveyRepository;

  Future<void> loadPatientSurveys({required int patientId}) async {
    emit(const PatientSurveysState.loading());

    final response = await _surveyRepository.getPatientSurveys(
      patientId: patientId,
    );

    response.when(
      success: (surveys, _) => emit(PatientSurveysState.loaded(surveys)),
      error: (message, _) => emit(PatientSurveysState.error(message)),
    );
  }
}
