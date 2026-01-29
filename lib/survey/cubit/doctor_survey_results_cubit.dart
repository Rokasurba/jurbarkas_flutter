import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/survey/cubit/doctor_survey_results_state.dart';
import 'package:frontend/survey/data/survey_repository.dart';

class DoctorSurveyResultsCubit extends Cubit<DoctorSurveyResultsState> {
  DoctorSurveyResultsCubit({required SurveyRepository surveyRepository})
      : _surveyRepository = surveyRepository,
        super(const DoctorSurveyResultsState.initial());

  final SurveyRepository _surveyRepository;

  Future<void> loadResults({
    required int surveyId,
    required int patientId,
  }) async {
    emit(const DoctorSurveyResultsState.loading());

    final response = await _surveyRepository.getDoctorSurveyResults(
      surveyId: surveyId,
      patientId: patientId,
    );

    response.when(
      success: (results, _) => emit(DoctorSurveyResultsState.loaded(results)),
      error: (message, _) => emit(DoctorSurveyResultsState.error(message)),
    );
  }
}
