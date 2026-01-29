import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/survey/cubit/aggregated_results_state.dart';
import 'package:frontend/survey/data/survey_repository.dart';

class AggregatedResultsCubit extends Cubit<AggregatedResultsState> {
  AggregatedResultsCubit({required SurveyRepository surveyRepository})
      : _surveyRepository = surveyRepository,
        super(const AggregatedResultsState.initial());

  final SurveyRepository _surveyRepository;

  Future<void> loadAggregatedResults({required int surveyId}) async {
    emit(const AggregatedResultsState.loading());

    final response = await _surveyRepository.getAggregatedSurveyResults(
      surveyId: surveyId,
    );

    response.when(
      success: (results, _) {
        if (results.totalCompleted == 0) {
          emit(const AggregatedResultsState.empty());
        } else {
          emit(AggregatedResultsState.loaded(results));
        }
      },
      error: (message, _) => emit(AggregatedResultsState.error(message)),
    );
  }

  Future<void> exportToCsv({required int surveyId}) async {
    final currentState = state;
    if (currentState is! AggregatedResultsLoaded) return;

    emit(AggregatedResultsState.exporting(currentState.results));

    final response = await _surveyRepository.exportAggregatedResults(
      surveyId: surveyId,
    );

    response.when(
      success: (csvData, _) {
        emit(AggregatedResultsState.exported(currentState.results, csvData));
        // Return to loaded state after export
        emit(AggregatedResultsState.loaded(currentState.results));
      },
      error: (message, _) {
        emit(AggregatedResultsState.error(message));
      },
    );
  }
}
