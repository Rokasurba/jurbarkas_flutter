import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/data/api_response.dart';
import 'package:frontend/survey/cubit/doctor_survey_results_cubit.dart';
import 'package:frontend/survey/cubit/doctor_survey_results_state.dart';
import 'package:frontend/survey/data/models/doctor_answer.dart';
import 'package:frontend/survey/data/models/doctor_survey_results.dart';
import 'package:frontend/survey/data/survey_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockSurveyRepository extends Mock implements SurveyRepository {}

void main() {
  late MockSurveyRepository mockRepository;

  const mockResults = DoctorSurveyResults(
    surveyId: 1,
    surveyTitle: 'Health Survey',
    patientId: 5,
    patientName: 'Jonas Jonaitis',
    completedAt: '2026-01-28T14:30:00Z',
    answers: const [
      DoctorAnswer(
        questionId: 1,
        questionText: 'How are you feeling?',
        questionType: 'single',
        isRequired: true,
        selectedOptionText: 'Good',
      ),
      DoctorAnswer(
        questionId: 2,
        questionText: 'Describe your symptoms',
        questionType: 'text',
        isRequired: false,
        textAnswer: 'Feeling better today',
      ),
    ],
  );

  setUp(() {
    mockRepository = MockSurveyRepository();
  });

  group('DoctorSurveyResultsCubit', () {
    test('initial state is DoctorSurveyResultsInitial', () {
      final cubit = DoctorSurveyResultsCubit(surveyRepository: mockRepository);
      expect(cubit.state, const DoctorSurveyResultsState.initial());
      cubit.close();
    });

    blocTest<DoctorSurveyResultsCubit, DoctorSurveyResultsState>(
      'emits [loading, loaded] when loadResults succeeds',
      build: () {
        when(
          () => mockRepository.getDoctorSurveyResults(
            surveyId: any(named: 'surveyId'),
            patientId: any(named: 'patientId'),
          ),
        ).thenAnswer((_) async => ApiResponse.success(data: mockResults));
        return DoctorSurveyResultsCubit(surveyRepository: mockRepository);
      },
      act: (cubit) => cubit.loadResults(surveyId: 1, patientId: 5),
      expect: () => [
        const DoctorSurveyResultsState.loading(),
        DoctorSurveyResultsState.loaded(mockResults),
      ],
    );

    blocTest<DoctorSurveyResultsCubit, DoctorSurveyResultsState>(
      'emits [loading, error] when loadResults fails',
      build: () {
        when(
          () => mockRepository.getDoctorSurveyResults(
            surveyId: any(named: 'surveyId'),
            patientId: any(named: 'patientId'),
          ),
        ).thenAnswer(
          (_) async => const ApiResponse.error(message: 'Not found'),
        );
        return DoctorSurveyResultsCubit(surveyRepository: mockRepository);
      },
      act: (cubit) => cubit.loadResults(surveyId: 1, patientId: 5),
      expect: () => [
        const DoctorSurveyResultsState.loading(),
        const DoctorSurveyResultsState.error('Not found'),
      ],
    );

    blocTest<DoctorSurveyResultsCubit, DoctorSurveyResultsState>(
      'calls repository with correct parameters',
      build: () {
        when(
          () => mockRepository.getDoctorSurveyResults(
            surveyId: any(named: 'surveyId'),
            patientId: any(named: 'patientId'),
          ),
        ).thenAnswer((_) async => ApiResponse.success(data: mockResults));
        return DoctorSurveyResultsCubit(surveyRepository: mockRepository);
      },
      act: (cubit) => cubit.loadResults(surveyId: 42, patientId: 123),
      verify: (_) {
        verify(
          () => mockRepository.getDoctorSurveyResults(
            surveyId: 42,
            patientId: 123,
          ),
        ).called(1);
      },
    );
  });

  group('DoctorSurveyResults model', () {
    test('correctly parses single choice answer', () {
      final answer = mockResults.answers.first;
      expect(answer.questionType, 'single');
      expect(answer.selectedOptionText, 'Good');
      expect(answer.textAnswer, isNull);
    });

    test('correctly parses text answer', () {
      final answer = mockResults.answers[1];
      expect(answer.questionType, 'text');
      expect(answer.textAnswer, 'Feeling better today');
      expect(answer.selectedOptionText, isNull);
    });
  });
}
