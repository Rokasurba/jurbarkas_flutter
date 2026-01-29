import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/survey/data/models/aggregated_survey_results.dart';

part 'aggregated_results_state.freezed.dart';

@freezed
sealed class AggregatedResultsState with _$AggregatedResultsState {
  const factory AggregatedResultsState.initial() = AggregatedResultsInitial;
  const factory AggregatedResultsState.loading() = AggregatedResultsLoading;
  const factory AggregatedResultsState.loaded(AggregatedSurveyResults results) =
      AggregatedResultsLoaded;
  const factory AggregatedResultsState.empty() = AggregatedResultsEmpty;
  const factory AggregatedResultsState.exporting(
    AggregatedSurveyResults results,
  ) = AggregatedResultsExporting;
  const factory AggregatedResultsState.exported(
    AggregatedSurveyResults results,
    Uint8List csvData,
  ) = AggregatedResultsExported;
  const factory AggregatedResultsState.error(String message) =
      AggregatedResultsError;
}
