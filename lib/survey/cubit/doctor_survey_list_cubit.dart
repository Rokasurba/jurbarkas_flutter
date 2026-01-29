import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/survey/cubit/doctor_survey_list_state.dart';
import 'package:frontend/survey/data/survey_repository.dart';

class DoctorSurveyListCubit extends Cubit<DoctorSurveyListState> {
  DoctorSurveyListCubit({required SurveyRepository surveyRepository})
      : _surveyRepository = surveyRepository,
        super(const DoctorSurveyListState.initial());

  final SurveyRepository _surveyRepository;

  Future<void> loadSurveys() async {
    emit(const DoctorSurveyListState.loading());

    final response = await _surveyRepository.getSurveys();

    response.when(
      success: (surveys, _) => emit(DoctorSurveyListState.loaded(surveys)),
      error: (message, _) => emit(DoctorSurveyListState.error(message)),
    );
  }
}
