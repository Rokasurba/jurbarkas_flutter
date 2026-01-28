import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/data/api_response.dart';
import 'package:frontend/patients/cubit/patients_cubit.dart';
import 'package:frontend/patients/data/models/patient_list_item.dart';
import 'package:frontend/patients/data/models/patient_list_params.dart';
import 'package:frontend/patients/data/patients_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockPatientsRepository extends Mock implements PatientsRepository {}

class FakePatientListParams extends Fake implements PatientListParams {}

void main() {
  late MockPatientsRepository mockRepository;

  const mockPatient1 = PatientListItem(
    id: 1,
    name: 'Petras',
    surname: 'Petraitis',
    email: 'petras@example.com',
    patientCode: 'JRB-001',
  );

  const mockPatient2 = PatientListItem(
    id: 2,
    name: 'Jonas',
    surname: 'Jonaitis',
    email: 'jonas@example.com',
    patientCode: 'JRB-002',
  );

  const mockPatient3 = PatientListItem(
    id: 3,
    name: 'Ona',
    surname: 'Onaitė',
    email: 'ona@example.com',
  );

  const mockPatientsResponse = PatientsResponse(
    patients: [mockPatient1, mockPatient2],
    total: 5,
    hasMore: true,
  );

  const mockPatientsResponsePage2 = PatientsResponse(
    patients: [mockPatient3],
    total: 5,
    hasMore: false,
  );

  const mockEmptyResponse = PatientsResponse(
    patients: [],
    total: 0,
    hasMore: false,
  );

  setUpAll(() {
    registerFallbackValue(FakePatientListParams());
  });

  setUp(() {
    mockRepository = MockPatientsRepository();
  });

  group('PatientsCubit', () {
    test('initial state is PatientsInitial', () {
      final cubit = PatientsCubit(patientsRepository: mockRepository);
      expect(cubit.state, const PatientsState.initial());
      cubit.close();
    });

    blocTest<PatientsCubit, PatientsState>(
      'emits [loading, loaded] when loadPatients succeeds',
      build: () {
        when(
          () => mockRepository.getPatients(params: any(named: 'params')),
        ).thenAnswer((_) async => ApiResponse.success(data: mockPatientsResponse));
        return PatientsCubit(patientsRepository: mockRepository);
      },
      act: (cubit) => cubit.loadPatients(),
      expect: () => [
        const PatientsState.loading(),
        PatientsState.loaded(
          patients: mockPatientsResponse.patients,
          total: mockPatientsResponse.total,
          hasMore: mockPatientsResponse.hasMore,
        ),
      ],
    );

    blocTest<PatientsCubit, PatientsState>(
      'emits [loading, loaded] with empty list when no patients',
      build: () {
        when(
          () => mockRepository.getPatients(params: any(named: 'params')),
        ).thenAnswer((_) async => const ApiResponse.success(data: mockEmptyResponse));
        return PatientsCubit(patientsRepository: mockRepository);
      },
      act: (cubit) => cubit.loadPatients(),
      expect: () => [
        const PatientsState.loading(),
        const PatientsState.loaded(
          patients: [],
          total: 0,
          hasMore: false,
        ),
      ],
    );

    blocTest<PatientsCubit, PatientsState>(
      'emits [loading, error] when loadPatients fails',
      build: () {
        when(
          () => mockRepository.getPatients(params: any(named: 'params')),
        ).thenAnswer((_) async => const ApiResponse.error(message: 'Network error'));
        return PatientsCubit(patientsRepository: mockRepository);
      },
      act: (cubit) => cubit.loadPatients(),
      expect: () => [
        const PatientsState.loading(),
        const PatientsState.error('Network error'),
      ],
    );

    blocTest<PatientsCubit, PatientsState>(
      'loadMore appends patients when successful',
      build: () {
        when(
          () => mockRepository.getPatients(params: any(named: 'params')),
        ).thenAnswer((_) async => ApiResponse.success(data: mockPatientsResponsePage2));
        return PatientsCubit(patientsRepository: mockRepository);
      },
      seed: () => PatientsState.loaded(
        patients: mockPatientsResponse.patients,
        total: mockPatientsResponse.total,
        hasMore: true,
      ),
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        PatientsState.loaded(
          patients: mockPatientsResponse.patients,
          total: mockPatientsResponse.total,
          hasMore: true,
          isLoadingMore: true,
        ),
        PatientsState.loaded(
          patients: [...mockPatientsResponse.patients, mockPatient3],
          total: mockPatientsResponsePage2.total,
          hasMore: false,
        ),
      ],
    );

    blocTest<PatientsCubit, PatientsState>(
      'loadMore does nothing when hasMore is false',
      build: () => PatientsCubit(patientsRepository: mockRepository),
      seed: () => PatientsState.loaded(
        patients: mockPatientsResponse.patients,
        total: mockPatientsResponse.total,
        hasMore: false,
      ),
      act: (cubit) => cubit.loadMore(),
      expect: () => <PatientsState>[],
      verify: (_) {
        verifyNever(
          () => mockRepository.getPatients(params: any(named: 'params')),
        );
      },
    );

    blocTest<PatientsCubit, PatientsState>(
      'loadMore does nothing when already loading more',
      build: () => PatientsCubit(patientsRepository: mockRepository),
      seed: () => PatientsState.loaded(
        patients: mockPatientsResponse.patients,
        total: mockPatientsResponse.total,
        hasMore: true,
        isLoadingMore: true,
      ),
      act: (cubit) => cubit.loadMore(),
      expect: () => <PatientsState>[],
      verify: (_) {
        verifyNever(
          () => mockRepository.getPatients(params: any(named: 'params')),
        );
      },
    );

    blocTest<PatientsCubit, PatientsState>(
      'loadMore does nothing when state is not loaded',
      build: () => PatientsCubit(patientsRepository: mockRepository),
      seed: () => const PatientsState.loading(),
      act: (cubit) => cubit.loadMore(),
      expect: () => <PatientsState>[],
      verify: (_) {
        verifyNever(
          () => mockRepository.getPatients(params: any(named: 'params')),
        );
      },
    );

    blocTest<PatientsCubit, PatientsState>(
      'loadMore restores state on error',
      build: () {
        when(
          () => mockRepository.getPatients(params: any(named: 'params')),
        ).thenAnswer((_) async => const ApiResponse.error(message: 'Network error'));
        return PatientsCubit(patientsRepository: mockRepository);
      },
      seed: () => PatientsState.loaded(
        patients: mockPatientsResponse.patients,
        total: mockPatientsResponse.total,
        hasMore: true,
      ),
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        PatientsState.loaded(
          patients: mockPatientsResponse.patients,
          total: mockPatientsResponse.total,
          hasMore: true,
          isLoadingMore: true,
        ),
        PatientsState.loaded(
          patients: mockPatientsResponse.patients,
          total: mockPatientsResponse.total,
          hasMore: true,
        ),
      ],
    );
  });

  group('PatientsState', () {
    test('isLoading returns true only for loading state', () {
      expect(const PatientsState.initial().isLoading, isFalse);
      expect(const PatientsState.loading().isLoading, isTrue);
      expect(
        const PatientsState.loaded(patients: [], total: 0, hasMore: false).isLoading,
        isFalse,
      );
      expect(const PatientsState.error('error').isLoading, isFalse);
    });

    test('patients returns list for loaded state, empty for others', () {
      expect(const PatientsState.initial().patients, isEmpty);
      expect(const PatientsState.loading().patients, isEmpty);
      expect(
        const PatientsState.loaded(
          patients: [mockPatient1],
          total: 1,
          hasMore: false,
        ).patients,
        [mockPatient1],
      );
      expect(const PatientsState.error('error').patients, isEmpty);
    });

    test('total returns count for loaded state, 0 for others', () {
      expect(const PatientsState.initial().total, 0);
      expect(const PatientsState.loading().total, 0);
      expect(
        const PatientsState.loaded(patients: [], total: 42, hasMore: false).total,
        42,
      );
      expect(const PatientsState.error('error').total, 0);
    });

    test('hasMore returns value for loaded state, false for others', () {
      expect(const PatientsState.initial().hasMore, isFalse);
      expect(const PatientsState.loading().hasMore, isFalse);
      expect(
        const PatientsState.loaded(patients: [], total: 10, hasMore: true).hasMore,
        isTrue,
      );
      expect(const PatientsState.error('error').hasMore, isFalse);
    });

    test('isLoadingMore returns value for loaded state, false for others', () {
      expect(const PatientsState.initial().isLoadingMore, isFalse);
      expect(const PatientsState.loading().isLoadingMore, isFalse);
      expect(
        const PatientsState.loaded(
          patients: [],
          total: 0,
          hasMore: false,
          isLoadingMore: true,
        ).isLoadingMore,
        isTrue,
      );
      expect(const PatientsState.error('error').isLoadingMore, isFalse);
    });
  });

  group('PatientListItem', () {
    test('fullName combines name and surname', () {
      expect(mockPatient1.fullName, 'Petras Petraitis');
      expect(mockPatient2.fullName, 'Jonas Jonaitis');
    });

    test('initials returns first letters of name and surname', () {
      expect(mockPatient1.initials, 'PP');
      expect(mockPatient2.initials, 'JJ');
      expect(mockPatient3.initials, 'OO');
    });

    test('initials handles empty name or surname gracefully', () {
      const patientEmptyName = PatientListItem(
        id: 99,
        name: '',
        surname: 'Test',
        email: 'test@example.com',
      );
      const patientEmptySurname = PatientListItem(
        id: 100,
        name: 'Test',
        surname: '',
        email: 'test@example.com',
      );
      expect(patientEmptyName.initials, 'T');
      expect(patientEmptySurname.initials, 'T');
    });

    test('patientCode can be null', () {
      expect(mockPatient1.patientCode, 'JRB-001');
      expect(mockPatient3.patientCode, isNull);
    });
  });
}
