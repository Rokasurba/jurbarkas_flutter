import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/data/api_response.dart';
import 'package:frontend/survey/cubit/aggregated_results_cubit.dart';
import 'package:frontend/survey/cubit/aggregated_results_state.dart';
import 'package:frontend/survey/data/models/aggregated_question.dart';
import 'package:frontend/survey/data/models/aggregated_survey_results.dart';
import 'package:frontend/survey/data/survey_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockSurveyRepository extends Mock implements SurveyRepository {}

void main() {
  late MockSurveyRepository mockRepository;

  final mockResults = AggregatedSurveyResults(
    surveyId: 1,
    surveyTitle: 'Health Survey',
    totalAssigned: 10,
    totalCompleted: 5,
    completionRate: 50.0,
    questions: const [
      AggregatedQuestion(
        questionId: 1,
        questionText: 'How are you feeling?',
        questionType: 'single',
        isRequired: true,
        totalResponses: 5,
      ),
    ],
  );

  final emptyResults = AggregatedSurveyResults(
    surveyId: 1,
    surveyTitle: 'Empty Survey',
    totalAssigned: 10,
    totalCompleted: 0,
    completionRate: 0.0,
    questions: const [],
  );

  setUp(() {
    mockRepository = MockSurveyRepository();
  });

  group('AggregatedResultsCubit', () {
    test('initial state is AggregatedResultsInitial', () {
      final cubit = AggregatedResultsCubit(surveyRepository: mockRepository);
      expect(cubit.state, const AggregatedResultsState.initial());
      cubit.close();
    });

    blocTest<AggregatedResultsCubit, AggregatedResultsState>(
      'emits [loading, loaded] when loadAggregatedResults succeeds',
      build: () {
        when(
          () => mockRepository.getAggregatedSurveyResults(
            surveyId: any(named: 'surveyId'),
          ),
        ).thenAnswer((_) async => ApiResponse.success(data: mockResults));
        return AggregatedResultsCubit(surveyRepository: mockRepository);
      },
      act: (cubit) => cubit.loadAggregatedResults(surveyId: 1),
      expect: () => [
        const AggregatedResultsState.loading(),
        AggregatedResultsState.loaded(mockResults),
      ],
    );

    blocTest<AggregatedResultsCubit, AggregatedResultsState>(
      'emits [loading, empty] when survey has no completed responses',
      build: () {
        when(
          () => mockRepository.getAggregatedSurveyResults(
            surveyId: any(named: 'surveyId'),
          ),
        ).thenAnswer((_) async => ApiResponse.success(data: emptyResults));
        return AggregatedResultsCubit(surveyRepository: mockRepository);
      },
      act: (cubit) => cubit.loadAggregatedResults(surveyId: 1),
      expect: () => [
        const AggregatedResultsState.loading(),
        const AggregatedResultsState.empty(),
      ],
    );

    blocTest<AggregatedResultsCubit, AggregatedResultsState>(
      'emits [loading, error] when loadAggregatedResults fails',
      build: () {
        when(
          () => mockRepository.getAggregatedSurveyResults(
            surveyId: any(named: 'surveyId'),
          ),
        ).thenAnswer(
          (_) async => const ApiResponse.error(message: 'Network error'),
        );
        return AggregatedResultsCubit(surveyRepository: mockRepository);
      },
      act: (cubit) => cubit.loadAggregatedResults(surveyId: 1),
      expect: () => [
        const AggregatedResultsState.loading(),
        const AggregatedResultsState.error('Network error'),
      ],
    );

    blocTest<AggregatedResultsCubit, AggregatedResultsState>(
      'emits [exporting, exported, loaded] when exportToCsv succeeds',
      build: () {
        when(
          () => mockRepository.exportAggregatedResults(
            surveyId: any(named: 'surveyId'),
          ),
        ).thenAnswer(
          (_) async => ApiResponse.success(
            data: Uint8List.fromList([1, 2, 3]),
          ),
        );
        return AggregatedResultsCubit(surveyRepository: mockRepository);
      },
      seed: () => AggregatedResultsState.loaded(mockResults),
      act: (cubit) => cubit.exportToCsv(surveyId: 1),
      expect: () => [
        AggregatedResultsState.exporting(mockResults),
        isA<AggregatedResultsExported>(),
        AggregatedResultsState.loaded(mockResults),
      ],
    );

    blocTest<AggregatedResultsCubit, AggregatedResultsState>(
      'emits [exporting, error] when exportToCsv fails',
      build: () {
        when(
          () => mockRepository.exportAggregatedResults(
            surveyId: any(named: 'surveyId'),
          ),
        ).thenAnswer(
          (_) async => const ApiResponse.error(message: 'Export failed'),
        );
        return AggregatedResultsCubit(surveyRepository: mockRepository);
      },
      seed: () => AggregatedResultsState.loaded(mockResults),
      act: (cubit) => cubit.exportToCsv(surveyId: 1),
      expect: () => [
        AggregatedResultsState.exporting(mockResults),
        const AggregatedResultsState.error('Export failed'),
      ],
    );

    blocTest<AggregatedResultsCubit, AggregatedResultsState>(
      'exportToCsv does nothing when not in loaded state',
      build: () => AggregatedResultsCubit(surveyRepository: mockRepository),
      seed: () => const AggregatedResultsState.loading(),
      act: (cubit) => cubit.exportToCsv(surveyId: 1),
      expect: () => [],
      verify: (_) {
        verifyNever(
          () => mockRepository.exportAggregatedResults(
            surveyId: any(named: 'surveyId'),
          ),
        );
      },
    );
  });
}
