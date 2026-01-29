import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/survey/cubit/survey_list_state.dart';
import 'package:frontend/survey/data/survey_repository.dart';

class SurveyListCubit extends Cubit<SurveyListState> {
  SurveyListCubit({required SurveyRepository surveyRepository})
      : _surveyRepository = surveyRepository,
        super(const SurveyListState.initial());

  final SurveyRepository _surveyRepository;

  Future<void> loadAssignedSurveys() async {
    emit(const SurveyListState.loading());

    final response = await _surveyRepository.getAssignedSurveys();

    response.when(
      success: (surveys, _) => emit(SurveyListState.loaded(surveys)),
      error: (message, _) => emit(SurveyListState.error(message)),
    );
  }
}
