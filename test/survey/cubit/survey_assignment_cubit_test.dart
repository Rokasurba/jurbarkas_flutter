import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/data/api_response.dart';
import 'package:frontend/patients/data/models/patient_list_item.dart';
import 'package:frontend/patients/data/models/patient_list_params.dart';
import 'package:frontend/patients/data/patients_repository.dart';
import 'package:frontend/survey/cubit/survey_assignment_cubit.dart';
import 'package:frontend/survey/cubit/survey_assignment_state.dart';
import 'package:frontend/survey/data/models/assignment_result.dart';
import 'package:frontend/survey/data/survey_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockSurveyRepository extends Mock implements SurveyRepository {}

class MockPatientsRepository extends Mock implements PatientsRepository {}

void main() {
  late MockSurveyRepository mockSurveyRepository;
  late MockPatientsRepository mockPatientsRepository;

  final testPatients = [
    const PatientListItem(
      id: 1,
      name: 'Jonas',
      surname: 'Jonaitis',
      email: 'jonas@test.com',
    ),
    const PatientListItem(
      id: 2,
      name: 'Petras',
      surname: 'Petraitis',
      email: 'petras@test.com',
    ),
    const PatientListItem(
      id: 3,
      name: 'Marija',
      surname: 'Marijona',
      email: 'marija@test.com',
    ),
  ];

  setUpAll(() {
    registerFallbackValue(const PatientListParams.firstPage());
  });

  setUp(() {
    mockSurveyRepository = MockSurveyRepository();
    mockPatientsRepository = MockPatientsRepository();
  });

  group('SurveyAssignmentCubit', () {
    test('initial state is SurveyAssignmentInitial', () {
      final cubit = SurveyAssignmentCubit(
        surveyRepository: mockSurveyRepository,
        patientsRepository: mockPatientsRepository,
      );
      expect(cubit.state, equals(const SurveyAssignmentState.initial()));
      cubit.close();
    });

    blocTest<SurveyAssignmentCubit, SurveyAssignmentState>(
      'loadPatients populates patient list',
      build: () {
        when(() => mockPatientsRepository.getPatients(
              params: any(named: 'params'),
            )).thenAnswer(
          (_) async => ApiResponse.success(
            data: PatientsResponse(
              patients: testPatients,
              total: 3,
              hasMore: false,
            ),
          ),
        );
        return SurveyAssignmentCubit(
          surveyRepository: mockSurveyRepository,
          patientsRepository: mockPatientsRepository,
        );
      },
      act: (cubit) => cubit.loadPatients(1),
      expect: () => [
        const SurveyAssignmentState.loading(),
        isA<SurveyAssignmentLoaded>()
            .having((s) => s.allPatients.length, 'allPatients.length', 3)
            .having((s) => s.surveyId, 'surveyId', 1)
            .having((s) => s.selectedIds, 'selectedIds', <int>{}),
      ],
    );

    blocTest<SurveyAssignmentCubit, SurveyAssignmentState>(
      'togglePatient adds and removes from selection',
      build: () => SurveyAssignmentCubit(
        surveyRepository: mockSurveyRepository,
        patientsRepository: mockPatientsRepository,
      ),
      seed: () => SurveyAssignmentState.loaded(
        allPatients:
            testPatients.map((p) => PatientSelectionItem(patient: p)).toList(),
        filteredPatients:
            testPatients.map((p) => PatientSelectionItem(patient: p)).toList(),
        selectedIds: const {},
        surveyId: 1,
        searchQuery: '',
      ),
      act: (cubit) {
        cubit.togglePatient(1); // Select
        cubit.togglePatient(2); // Select
        cubit.togglePatient(1); // Deselect
      },
      expect: () => [
        isA<SurveyAssignmentLoaded>()
            .having((s) => s.selectedIds, 'selectedIds', {1}),
        isA<SurveyAssignmentLoaded>()
            .having((s) => s.selectedIds, 'selectedIds', {1, 2}),
        isA<SurveyAssignmentLoaded>()
            .having((s) => s.selectedIds, 'selectedIds', {2}),
      ],
    );

    blocTest<SurveyAssignmentCubit, SurveyAssignmentState>(
      'searchPatients filters the list',
      build: () => SurveyAssignmentCubit(
        surveyRepository: mockSurveyRepository,
        patientsRepository: mockPatientsRepository,
      ),
      seed: () => SurveyAssignmentState.loaded(
        allPatients:
            testPatients.map((p) => PatientSelectionItem(patient: p)).toList(),
        filteredPatients:
            testPatients.map((p) => PatientSelectionItem(patient: p)).toList(),
        selectedIds: const {},
        surveyId: 1,
        searchQuery: '',
      ),
      act: (cubit) => cubit.searchPatients('Jonas'),
      expect: () => [
        isA<SurveyAssignmentLoaded>()
            .having(
              (s) => s.filteredPatients.length,
              'filteredPatients.length',
              1,
            )
            .having(
              (s) => s.filteredPatients.first.patient.name,
              'first patient name',
              'Jonas',
            )
            .having((s) => s.searchQuery, 'searchQuery', 'Jonas'),
      ],
    );

    blocTest<SurveyAssignmentCubit, SurveyAssignmentState>(
      'assignToSelected emits assigning then assigned states',
      build: () {
        when(
          () => mockSurveyRepository.assignSurvey(
            surveyId: any(named: 'surveyId'),
            patientIds: any(named: 'patientIds'),
          ),
        ).thenAnswer(
          (_) async => const ApiResponse.success(
            data: AssignmentResult(
              assignedCount: 2,
              skippedCount: 0,
            ),
          ),
        );
        return SurveyAssignmentCubit(
          surveyRepository: mockSurveyRepository,
          patientsRepository: mockPatientsRepository,
        );
      },
      seed: () => SurveyAssignmentState.loaded(
        allPatients:
            testPatients.map((p) => PatientSelectionItem(patient: p)).toList(),
        filteredPatients:
            testPatients.map((p) => PatientSelectionItem(patient: p)).toList(),
        selectedIds: const {1, 2},
        surveyId: 1,
        searchQuery: '',
      ),
      act: (cubit) => cubit.assignToSelected(),
      expect: () => [
        isA<SurveyAssignmentAssigning>()
            .having((s) => s.selectedIds, 'selectedIds', {1, 2})
            .having((s) => s.surveyId, 'surveyId', 1),
        isA<SurveyAssignmentAssigned>()
            .having((s) => s.assignedCount, 'assignedCount', 2)
            .having((s) => s.skippedCount, 'skippedCount', 0),
      ],
    );

    blocTest<SurveyAssignmentCubit, SurveyAssignmentState>(
      'selectAll selects all visible non-assigned patients',
      build: () => SurveyAssignmentCubit(
        surveyRepository: mockSurveyRepository,
        patientsRepository: mockPatientsRepository,
      ),
      seed: () => SurveyAssignmentState.loaded(
        allPatients:
            testPatients.map((p) => PatientSelectionItem(patient: p)).toList(),
        filteredPatients:
            testPatients.map((p) => PatientSelectionItem(patient: p)).toList(),
        selectedIds: const {},
        surveyId: 1,
        searchQuery: '',
      ),
      act: (cubit) => cubit.selectAll(),
      expect: () => [
        isA<SurveyAssignmentLoaded>()
            .having((s) => s.selectedIds, 'selectedIds', {1, 2, 3}),
      ],
    );

    blocTest<SurveyAssignmentCubit, SurveyAssignmentState>(
      'deselectAll clears all selections',
      build: () => SurveyAssignmentCubit(
        surveyRepository: mockSurveyRepository,
        patientsRepository: mockPatientsRepository,
      ),
      seed: () => SurveyAssignmentState.loaded(
        allPatients:
            testPatients.map((p) => PatientSelectionItem(patient: p)).toList(),
        filteredPatients:
            testPatients.map((p) => PatientSelectionItem(patient: p)).toList(),
        selectedIds: const {1, 2, 3},
        surveyId: 1,
        searchQuery: '',
      ),
      act: (cubit) => cubit.deselectAll(),
      expect: () => [
        isA<SurveyAssignmentLoaded>()
            .having((s) => s.selectedIds, 'selectedIds', <int>{}),
      ],
    );

    blocTest<SurveyAssignmentCubit, SurveyAssignmentState>(
      'loadPatients emits error when getPatients fails',
      build: () {
        when(() => mockPatientsRepository.getPatients(
              params: any(named: 'params'),
            )).thenAnswer(
          (_) async => const ApiResponse.error(
            message: 'Network error',
          ),
        );
        return SurveyAssignmentCubit(
          surveyRepository: mockSurveyRepository,
          patientsRepository: mockPatientsRepository,
        );
      },
      act: (cubit) => cubit.loadPatients(1),
      expect: () => [
        const SurveyAssignmentState.loading(),
        isA<SurveyAssignmentError>()
            .having((s) => s.message, 'message', 'Network error'),
      ],
    );

    blocTest<SurveyAssignmentCubit, SurveyAssignmentState>(
      'reload calls loadPatients with last surveyId',
      build: () {
        when(() => mockPatientsRepository.getPatients(
              params: any(named: 'params'),
            )).thenAnswer(
          (_) async => ApiResponse.success(
            data: PatientsResponse(
              patients: testPatients,
              total: 3,
              hasMore: false,
            ),
          ),
        );
        return SurveyAssignmentCubit(
          surveyRepository: mockSurveyRepository,
          patientsRepository: mockPatientsRepository,
        );
      },
      act: (cubit) async {
        await cubit.loadPatients(1);
        await cubit.reload();
      },
      expect: () => [
        const SurveyAssignmentState.loading(),
        isA<SurveyAssignmentLoaded>()
            .having((s) => s.surveyId, 'surveyId', 1),
        const SurveyAssignmentState.loading(),
        isA<SurveyAssignmentLoaded>()
            .having((s) => s.surveyId, 'surveyId', 1),
      ],
    );
  });
}
