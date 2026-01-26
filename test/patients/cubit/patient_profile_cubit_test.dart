import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/data/api_response.dart';
import 'package:frontend/patients/cubit/patient_profile_cubit.dart';
import 'package:frontend/patients/data/models/patient_profile.dart';
import 'package:frontend/patients/data/patients_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockPatientsRepository extends Mock implements PatientsRepository {}

void main() {
  late MockPatientsRepository mockRepository;

  final mockProfile = PatientProfile(
    id: 1,
    name: 'Petras',
    surname: 'Petraitis',
    email: 'petras@example.com',
    phone: '+37061234567',
    dateOfBirth: DateTime(1956, 3, 15),
    patientCode: 'JRB-001',
    isActive: true,
    createdAt: DateTime(2026, 1, 10, 8, 30),
  );

  final mockProfileInactive = PatientProfile(
    id: 2,
    name: 'Jonas',
    surname: 'Jonaitis',
    email: 'jonas@example.com',
    isActive: false,
    createdAt: DateTime(2026, 1, 15),
  );

  setUp(() {
    mockRepository = MockPatientsRepository();
  });

  group('PatientProfileCubit', () {
    test('initial state is PatientProfileInitial', () {
      final cubit = PatientProfileCubit(
        patientsRepository: mockRepository,
        patientId: 1,
      );
      expect(cubit.state, const PatientProfileState.initial());
      cubit.close();
    });

    blocTest<PatientProfileCubit, PatientProfileState>(
      'emits [loading, loaded] when loadProfile succeeds',
      build: () {
        when(() => mockRepository.getPatientById(1))
            .thenAnswer((_) async => ApiResponse.success(data: mockProfile));
        return PatientProfileCubit(
          patientsRepository: mockRepository,
          patientId: 1,
        );
      },
      act: (cubit) => cubit.loadProfile(),
      expect: () => [
        const PatientProfileState.loading(),
        PatientProfileState.loaded(mockProfile),
      ],
    );

    blocTest<PatientProfileCubit, PatientProfileState>(
      'emits [loading, failure] when loadProfile fails',
      build: () {
        when(() => mockRepository.getPatientById(1)).thenAnswer(
          (_) async => const ApiResponse.error(message: 'Patient not found'),
        );
        return PatientProfileCubit(
          patientsRepository: mockRepository,
          patientId: 1,
        );
      },
      act: (cubit) => cubit.loadProfile(),
      expect: () => [
        const PatientProfileState.loading(),
        const PatientProfileState.failure('Patient not found'),
      ],
    );

    blocTest<PatientProfileCubit, PatientProfileState>(
      'refresh reloads the profile',
      build: () {
        when(() => mockRepository.getPatientById(2))
            .thenAnswer((_) async => ApiResponse.success(data: mockProfileInactive));
        return PatientProfileCubit(
          patientsRepository: mockRepository,
          patientId: 2,
        );
      },
      seed: () => PatientProfileState.loaded(mockProfile),
      act: (cubit) => cubit.refresh(),
      expect: () => [
        const PatientProfileState.loading(),
        PatientProfileState.loaded(mockProfileInactive),
      ],
    );
  });

  group('PatientProfileState', () {
    test('isLoading returns true only for loading state', () {
      expect(const PatientProfileState.initial().isLoading, isFalse);
      expect(const PatientProfileState.loading().isLoading, isTrue);
      expect(PatientProfileState.loaded(mockProfile).isLoading, isFalse);
      expect(const PatientProfileState.failure('error').isLoading, isFalse);
    });

    test('profileOrNull returns profile for loaded state, null for others', () {
      expect(const PatientProfileState.initial().profileOrNull, isNull);
      expect(const PatientProfileState.loading().profileOrNull, isNull);
      expect(
        PatientProfileState.loaded(mockProfile).profileOrNull,
        mockProfile,
      );
      expect(const PatientProfileState.failure('error').profileOrNull, isNull);
    });

    test('errorOrNull returns message for failure state, null for others', () {
      expect(const PatientProfileState.initial().errorOrNull, isNull);
      expect(const PatientProfileState.loading().errorOrNull, isNull);
      expect(PatientProfileState.loaded(mockProfile).errorOrNull, isNull);
      expect(
        const PatientProfileState.failure('Network error').errorOrNull,
        'Network error',
      );
    });
  });

  group('PatientProfile', () {
    test('fullName combines name and surname', () {
      expect(mockProfile.fullName, 'Petras Petraitis');
      expect(mockProfileInactive.fullName, 'Jonas Jonaitis');
    });

    test('initials returns first letters of name and surname', () {
      expect(mockProfile.initials, 'PP');
      expect(mockProfileInactive.initials, 'JJ');
    });

    test('initials handles empty name or surname gracefully', () {
      final profileEmptyName = PatientProfile(
        id: 99,
        name: '',
        surname: 'Test',
        email: 'test@example.com',
        isActive: true,
        createdAt: DateTime.now(),
      );
      final profileEmptySurname = PatientProfile(
        id: 100,
        name: 'Test',
        surname: '',
        email: 'test@example.com',
        isActive: true,
        createdAt: DateTime.now(),
      );
      expect(profileEmptyName.initials, 'T');
      expect(profileEmptySurname.initials, 'T');
    });

    test('optional fields can be null', () {
      expect(mockProfile.phone, '+37061234567');
      expect(mockProfile.dateOfBirth, DateTime(1956, 3, 15));
      expect(mockProfile.patientCode, 'JRB-001');

      expect(mockProfileInactive.phone, isNull);
      expect(mockProfileInactive.dateOfBirth, isNull);
      expect(mockProfileInactive.patientCode, isNull);
    });

    test('isActive distinguishes active and inactive patients', () {
      expect(mockProfile.isActive, isTrue);
      expect(mockProfileInactive.isActive, isFalse);
    });
  });
}
