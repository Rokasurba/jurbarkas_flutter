import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/admin/admin.dart';
import 'package:frontend/auth/data/models/user_model.dart';
import 'package:frontend/core/data/api_response.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminRepository extends Mock implements AdminRepository {}

class FakeUpdatePatientRequest extends Fake implements UpdatePatientRequest {}

void main() {
  late AdminRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeUpdatePatientRequest());
  });

  setUp(() {
    mockRepository = MockAdminRepository();
  });

  group('AdminPatientDetailCubit', () {
    const testUser = User(
      id: 1,
      name: 'Jonas',
      surname: 'Jonaitis',
      email: 'jonas@test.com',
      role: 'patient',
    );

    group('updatePatient', () {
      blocTest<AdminPatientDetailCubit, AdminPatientDetailState>(
        'emits [updating, updateSuccess] when update succeeds',
        build: () {
          when(
            () => mockRepository.updatePatient(any(), any()),
          ).thenAnswer((_) async => const ApiResponse.success(data: testUser));
          return AdminPatientDetailCubit(adminRepository: mockRepository);
        },
        act: (cubit) => cubit.updatePatient(
          1,
          const UpdatePatientRequest(name: 'Jonas', surname: 'Jonaitis'),
        ),
        expect: () => [
          const AdminPatientDetailState.updating(),
          const AdminPatientDetailState.updateSuccess(testUser),
        ],
      );

      blocTest<AdminPatientDetailCubit, AdminPatientDetailState>(
        'emits [updating, error] when update fails',
        build: () {
          when(() => mockRepository.updatePatient(any(), any())).thenAnswer(
            (_) async => const ApiResponse.error(message: 'Update failed'),
          );
          return AdminPatientDetailCubit(adminRepository: mockRepository);
        },
        act: (cubit) => cubit.updatePatient(
          1,
          const UpdatePatientRequest(name: 'Jonas'),
        ),
        expect: () => [
          const AdminPatientDetailState.updating(),
          const AdminPatientDetailState.error('Update failed'),
        ],
      );
    });

    group('deactivatePatient', () {
      blocTest<AdminPatientDetailCubit, AdminPatientDetailState>(
        'emits [updating, deactivated] when deactivation succeeds',
        build: () {
          when(
            () => mockRepository.deactivatePatient(any()),
          ).thenAnswer((_) async => const ApiResponse.success(data: null));
          return AdminPatientDetailCubit(adminRepository: mockRepository);
        },
        act: (cubit) => cubit.deactivatePatient(1),
        expect: () => [
          const AdminPatientDetailState.updating(),
          const AdminPatientDetailState.deactivated(),
        ],
      );

      blocTest<AdminPatientDetailCubit, AdminPatientDetailState>(
        'emits [updating, error] when deactivation fails',
        build: () {
          when(() => mockRepository.deactivatePatient(any())).thenAnswer(
            (_) async =>
                const ApiResponse.error(message: 'Deactivation failed'),
          );
          return AdminPatientDetailCubit(adminRepository: mockRepository);
        },
        act: (cubit) => cubit.deactivatePatient(1),
        expect: () => [
          const AdminPatientDetailState.updating(),
          const AdminPatientDetailState.error('Deactivation failed'),
        ],
      );
    });

    group('reactivatePatient', () {
      blocTest<AdminPatientDetailCubit, AdminPatientDetailState>(
        'emits [updating, reactivated] when reactivation succeeds',
        build: () {
          when(
            () => mockRepository.reactivatePatient(any()),
          ).thenAnswer((_) async => const ApiResponse.success(data: testUser));
          return AdminPatientDetailCubit(adminRepository: mockRepository);
        },
        act: (cubit) => cubit.reactivatePatient(1),
        expect: () => [
          const AdminPatientDetailState.updating(),
          const AdminPatientDetailState.reactivated(testUser),
        ],
      );

      blocTest<AdminPatientDetailCubit, AdminPatientDetailState>(
        'emits [updating, error] when reactivation fails',
        build: () {
          when(() => mockRepository.reactivatePatient(any())).thenAnswer(
            (_) async =>
                const ApiResponse.error(message: 'Reactivation failed'),
          );
          return AdminPatientDetailCubit(adminRepository: mockRepository);
        },
        act: (cubit) => cubit.reactivatePatient(1),
        expect: () => [
          const AdminPatientDetailState.updating(),
          const AdminPatientDetailState.error('Reactivation failed'),
        ],
      );
    });
  });
}
