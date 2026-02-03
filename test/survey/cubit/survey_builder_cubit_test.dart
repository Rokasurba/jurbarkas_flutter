import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/data/api_response.dart';
import 'package:frontend/survey/cubit/survey_builder_cubit.dart';
import 'package:frontend/survey/cubit/survey_builder_state.dart';
import 'package:frontend/survey/data/models/create_survey_request.dart';
import 'package:frontend/survey/data/models/question_form_data.dart';
import 'package:frontend/survey/data/models/survey.dart';
import 'package:frontend/survey/data/models/survey_details.dart';
import 'package:frontend/survey/data/models/survey_option.dart';
import 'package:frontend/survey/data/models/survey_question.dart';
import 'package:frontend/survey/data/survey_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockSurveyRepository extends Mock implements SurveyRepository {}

void main() {
  late MockSurveyRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(
      const CreateSurveyRequest(
        title: 'Test',
        questions: [],
      ),
    );
  });

  setUp(() {
    mockRepository = MockSurveyRepository();
  });

  group('SurveyBuilderCubit', () {
    test('initial state is SurveyBuilderInitial', () {
      final cubit = SurveyBuilderCubit(surveyRepository: mockRepository);
      expect(cubit.state, equals(const SurveyBuilderState.initial()));
      cubit.close();
    });

    blocTest<SurveyBuilderCubit, SurveyBuilderState>(
      'initForCreate sets initial editing state',
      build: () => SurveyBuilderCubit(surveyRepository: mockRepository),
      act: (cubit) => cubit.initForCreate(),
      expect: () => [
        const SurveyBuilderState.editing(
          title: '',
          description: null,
          questions: [],
          isEditMode: false,
          hasResponses: false,
          surveyId: null,
        ),
      ],
    );

    blocTest<SurveyBuilderCubit, SurveyBuilderState>(
      'initForEdit loads existing survey data',
      build: () {
        when(() => mockRepository.getSurveyDetails(any())).thenAnswer(
          (_) async => const ApiResponse.success(
            data: SurveyDetails(
              id: 1,
              title: 'Existing Survey',
              description: 'Test description',
              isActive: true,
              createdBy: 1,
              creatorName: 'Doctor',
              createdAt: '2026-01-01',
              questionCount: 1,
              assignmentCount: 0,
              questions: [
                SurveyQuestion(
                  id: 1,
                  questionText: 'Question 1',
                  questionType: 'single',
                  isRequired: true,
                  orderIndex: 0,
                  options: [
                    SurveyOption(
                      id: 1,
                      optionText: 'Option 1',
                      orderIndex: 0,
                    ),
                    SurveyOption(
                      id: 2,
                      optionText: 'Option 2',
                      orderIndex: 1,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
        return SurveyBuilderCubit(surveyRepository: mockRepository);
      },
      act: (cubit) => cubit.initForEdit(1),
      expect: () => [
        const SurveyBuilderState.loading(),
        isA<SurveyBuilderEditing>()
            .having((s) => s.title, 'title', 'Existing Survey')
            .having((s) => s.description, 'description', 'Test description')
            .having((s) => s.isEditMode, 'isEditMode', true)
            .having((s) => s.surveyId, 'surveyId', 1)
            .having((s) => s.questions.length, 'questions.length', 1),
      ],
    );

    blocTest<SurveyBuilderCubit, SurveyBuilderState>(
      'addQuestion adds to questions list',
      build: () => SurveyBuilderCubit(surveyRepository: mockRepository),
      seed: () => const SurveyBuilderState.editing(
        title: 'Test',
        description: null,
        questions: [],
        isEditMode: false,
        hasResponses: false,
        surveyId: null,
      ),
      act: (cubit) => cubit.addQuestion(
        QuestionFormData(
          questionText: 'New Question',
          options: [
            OptionFormData(optionText: 'A'),
            OptionFormData(optionText: 'B', orderIndex: 1),
          ],
        ),
      ),
      expect: () => [
        isA<SurveyBuilderEditing>()
            .having((s) => s.questions.length, 'questions.length', 1)
            .having(
              (s) => s.questions.first.questionText,
              'questionText',
              'New Question',
            ),
      ],
    );

    blocTest<SurveyBuilderCubit, SurveyBuilderState>(
      'removeQuestion removes from list',
      build: () => SurveyBuilderCubit(surveyRepository: mockRepository),
      seed: () => SurveyBuilderState.editing(
        title: 'Test',
        description: null,
        questions: [
          QuestionFormData(
            questionText: 'Q1',
            options: [],
          ),
          QuestionFormData(
            questionText: 'Q2',
            questionType: 'text',
            isRequired: false,
            orderIndex: 1,
            options: [],
          ),
        ],
        isEditMode: false,
        hasResponses: false,
        surveyId: null,
      ),
      act: (cubit) => cubit.removeQuestion(0),
      expect: () => [
        isA<SurveyBuilderEditing>()
            .having((s) => s.questions.length, 'questions.length', 1)
            .having(
              (s) => s.questions.first.questionText,
              'questionText',
              'Q2',
            ),
      ],
    );

    blocTest<SurveyBuilderCubit, SurveyBuilderState>(
      'saveSurvey emits saving then saved states',
      build: () {
        when(() => mockRepository.createSurvey(any())).thenAnswer(
          (_) async => const ApiResponse.success(
            data: Survey(
              id: 1,
              title: 'New Survey',
              createdBy: 1,
              creatorName: 'Doctor',
              isActive: true,
              questionCount: 1,
              assignmentCount: 0,
              createdAt: '2026-01-30',
            ),
          ),
        );
        return SurveyBuilderCubit(surveyRepository: mockRepository);
      },
      seed: () => SurveyBuilderState.editing(
        title: 'New Survey',
        description: null,
        questions: [
          QuestionFormData(
            questionText: 'Q1',
            questionType: 'text',
            options: [],
          ),
        ],
        isEditMode: false,
        hasResponses: false,
        surveyId: null,
      ),
      act: (cubit) => cubit.saveSurvey(),
      expect: () => [
        isA<SurveyBuilderSaving>(),
        isA<SurveyBuilderSaved>()
            .having((s) => s.survey.id, 'survey.id', 1)
            .having((s) => s.survey.title, 'survey.title', 'New Survey'),
      ],
    );

    blocTest<SurveyBuilderCubit, SurveyBuilderState>(
      'saveSurvey emits validation error for empty title',
      build: () => SurveyBuilderCubit(surveyRepository: mockRepository),
      seed: () => SurveyBuilderState.editing(
        title: '',
        description: null,
        questions: [
          QuestionFormData(
            questionText: 'Q1',
            questionType: 'text',
            options: [],
          ),
        ],
        isEditMode: false,
        hasResponses: false,
        surveyId: null,
      ),
      act: (cubit) => cubit.saveSurvey(),
      expect: () => [
        isA<SurveyBuilderEditing>()
            .having((s) => s.titleError, 'titleError', 'title_required'),
      ],
    );

    blocTest<SurveyBuilderCubit, SurveyBuilderState>(
      'saveSurvey emits validation error for zero questions',
      build: () => SurveyBuilderCubit(surveyRepository: mockRepository),
      seed: () => const SurveyBuilderState.editing(
        title: 'Valid Title',
        description: null,
        questions: [],
        isEditMode: false,
        hasResponses: false,
        surveyId: null,
      ),
      act: (cubit) => cubit.saveSurvey(),
      expect: () => [
        isA<SurveyBuilderEditing>()
            .having(
              (s) => s.questionsError,
              'questionsError',
              'questions_required',
            ),
      ],
    );

    blocTest<SurveyBuilderCubit, SurveyBuilderState>(
      'saveSurvey in edit mode calls updateSurvey',
      build: () {
        when(() => mockRepository.updateSurvey(any(), any())).thenAnswer(
          (_) async => const ApiResponse.success(
            data: Survey(
              id: 1,
              title: 'Updated Survey',
              createdBy: 1,
              creatorName: 'Doctor',
              isActive: true,
              questionCount: 1,
              assignmentCount: 0,
              createdAt: '2026-01-30',
            ),
          ),
        );
        return SurveyBuilderCubit(surveyRepository: mockRepository);
      },
      seed: () => SurveyBuilderState.editing(
        title: 'Updated Survey',
        description: 'Updated desc',
        questions: [
          QuestionFormData(
            questionText: 'Q1',
            questionType: 'text',
            options: [],
          ),
        ],
        isEditMode: true,
        hasResponses: false,
        surveyId: 1,
      ),
      act: (cubit) => cubit.saveSurvey(),
      expect: () => [
        isA<SurveyBuilderSaving>().having((s) => s.isEditMode, 'isEditMode', true),
        isA<SurveyBuilderSaved>()
            .having((s) => s.survey.id, 'survey.id', 1)
            .having((s) => s.survey.title, 'survey.title', 'Updated Survey'),
      ],
      verify: (_) {
        verify(() => mockRepository.updateSurvey(1, any())).called(1);
      },
    );

    blocTest<SurveyBuilderCubit, SurveyBuilderState>(
      'reorderQuestions updates order correctly',
      build: () => SurveyBuilderCubit(surveyRepository: mockRepository),
      seed: () => SurveyBuilderState.editing(
        title: 'Test',
        description: null,
        questions: [
          QuestionFormData(
            questionText: 'Q1',
            questionType: 'text',
            options: [],
          ),
          QuestionFormData(
            questionText: 'Q2',
            questionType: 'text',
            orderIndex: 1,
            options: [],
          ),
          QuestionFormData(
            questionText: 'Q3',
            questionType: 'text',
            orderIndex: 2,
            options: [],
          ),
        ],
        isEditMode: false,
        hasResponses: false,
        surveyId: null,
      ),
      act: (cubit) => cubit.reorderQuestions(0, 3), // Move Q1 to end
      expect: () => [
        isA<SurveyBuilderEditing>()
            .having((s) => s.questions.length, 'questions.length', 3)
            .having(
              (s) => s.questions[0].questionText,
              'first question',
              'Q2',
            )
            .having(
              (s) => s.questions[2].questionText,
              'last question',
              'Q1',
            ),
      ],
    );
  });
}
