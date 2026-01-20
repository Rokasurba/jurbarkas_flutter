import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/blood_pressure/data/models/blood_pressure_reading.dart';
import 'package:frontend/blood_sugar/data/models/blood_sugar_reading.dart';
import 'package:frontend/bmi/data/models/bmi_measurement.dart';
import 'package:frontend/core/data/api_response.dart';
import 'package:frontend/dashboard/cubit/dashboard_cubit.dart';
import 'package:frontend/dashboard/data/models/dashboard_response.dart';
import 'package:frontend/dashboard/data/models/user_profile.dart';
import 'package:frontend/dashboard/data/repositories/dashboard_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late MockDashboardRepository mockRepository;

  const mockUserProfile = UserProfile(
    id: 1,
    name: 'Jonas',
    surname: 'Petraitis',
    email: 'jonas@example.com',
    phone: '+37061234567',
    dateOfBirth: '1990-05-15',
    role: 'patient',
  );

  final mockBloodPressure = BloodPressureReading(
    id: 1,
    systolic: 120,
    diastolic: 80,
    measuredAt: DateTime(2026, 1, 20, 10, 30),
  );

  final mockBmi = BmiMeasurement(
    id: 1,
    heightCm: 180,
    weightKg: 75.0,
    bmiValue: 23.15,
    measuredAt: DateTime(2026, 1, 19, 14),
  );

  final mockBloodSugar = BloodSugarReading(
    id: 1,
    glucoseLevel: 5.6,
    measuredAt: DateTime(2026, 1, 18, 8),
  );

  final mockDashboardResponse = DashboardResponse(
    user: mockUserProfile,
    latestBloodPressure: mockBloodPressure,
    latestBmi: mockBmi,
    latestBloodSugar: mockBloodSugar,
  );

  const mockDashboardResponseNoReadings = DashboardResponse(
    user: mockUserProfile,
  );

  setUp(() {
    mockRepository = MockDashboardRepository();
  });

  group('DashboardCubit', () {
    test('initial state is DashboardInitial', () {
      final cubit = DashboardCubit(dashboardRepository: mockRepository);
      expect(cubit.state, const DashboardState.initial());
      cubit.close();
    });

    blocTest<DashboardCubit, DashboardState>(
      'emits [loading, loaded] when loadDashboard succeeds with all readings',
      build: () {
        when(() => mockRepository.getDashboard()).thenAnswer(
          (_) async => ApiResponse.success(data: mockDashboardResponse),
        );
        return DashboardCubit(dashboardRepository: mockRepository);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const DashboardState.loading(),
        DashboardState.loaded(mockDashboardResponse),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits [loading, loaded] when loadDashboard succeeds with no readings',
      build: () {
        when(() => mockRepository.getDashboard()).thenAnswer(
          (_) async =>
              ApiResponse.success(data: mockDashboardResponseNoReadings),
        );
        return DashboardCubit(dashboardRepository: mockRepository);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const DashboardState.loading(),
        DashboardState.loaded(mockDashboardResponseNoReadings),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits [loading, failure] when loadDashboard fails',
      build: () {
        when(() => mockRepository.getDashboard()).thenAnswer(
          (_) async => const ApiResponse.error(message: 'Network error'),
        );
        return DashboardCubit(dashboardRepository: mockRepository);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const DashboardState.loading(),
        const DashboardState.failure('Network error'),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'refresh emits [loaded] when succeeds without loading state',
      build: () {
        when(() => mockRepository.getDashboard()).thenAnswer(
          (_) async => ApiResponse.success(data: mockDashboardResponse),
        );
        return DashboardCubit(dashboardRepository: mockRepository);
      },
      seed: () => DashboardState.loaded(mockDashboardResponseNoReadings),
      act: (cubit) => cubit.refresh(),
      expect: () => [
        DashboardState.loaded(mockDashboardResponse),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'refresh emits [failure] when fails',
      build: () {
        when(() => mockRepository.getDashboard()).thenAnswer(
          (_) async => const ApiResponse.error(message: 'Server error'),
        );
        return DashboardCubit(dashboardRepository: mockRepository);
      },
      seed: () => DashboardState.loaded(mockDashboardResponse),
      act: (cubit) => cubit.refresh(),
      expect: () => [
        const DashboardState.failure('Server error'),
      ],
    );
  });

  group('DashboardState', () {
    test('isLoading returns true for loading state', () {
      const state = DashboardState.loading();
      expect(state.isLoading, isTrue);
    });

    test('isLoading returns false for other states', () {
      const initialState = DashboardState.initial();
      final loadedState = DashboardState.loaded(mockDashboardResponse);
      const failureState = DashboardState.failure('error');

      expect(initialState.isLoading, isFalse);
      expect(loadedState.isLoading, isFalse);
      expect(failureState.isLoading, isFalse);
    });

    test('data returns DashboardResponse for loaded state', () {
      final state = DashboardState.loaded(mockDashboardResponse);
      expect(state.data, mockDashboardResponse);
    });

    test('data returns null for non-loaded states', () {
      const initialState = DashboardState.initial();
      const loadingState = DashboardState.loading();
      const failureState = DashboardState.failure('error');

      expect(initialState.data, isNull);
      expect(loadingState.data, isNull);
      expect(failureState.data, isNull);
    });
  });
}
