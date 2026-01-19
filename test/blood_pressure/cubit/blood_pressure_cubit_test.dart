import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/blood_pressure/cubit/blood_pressure_cubit.dart';
import 'package:frontend/blood_pressure/data/models/blood_pressure_reading.dart';
import 'package:frontend/blood_pressure/data/repositories/blood_pressure_repository.dart';
import 'package:frontend/core/data/api_response.dart';
import 'package:mocktail/mocktail.dart';

class MockBloodPressureRepository extends Mock
    implements BloodPressureRepository {}

void main() {
  late MockBloodPressureRepository mockRepository;

  final mockReading = BloodPressureReading(
    id: 1,
    systolic: 120,
    diastolic: 80,
    measuredAt: DateTime(2026, 1, 19, 14, 30),
  );

  final mockReadings = [
    mockReading,
    BloodPressureReading(
      id: 2,
      systolic: 130,
      diastolic: 85,
      measuredAt: DateTime(2026, 1, 18, 10),
    ),
  ];

  setUp(() {
    mockRepository = MockBloodPressureRepository();
  });

  group('BloodPressureCubit', () {
    test('initial state is BloodPressureInitial', () {
      final cubit = BloodPressureCubit(bloodPressureRepository: mockRepository);
      expect(cubit.state, const BloodPressureState.initial());
      cubit.close();
    });

    blocTest<BloodPressureCubit, BloodPressureState>(
      'emits [loading, loaded] when loadHistory succeeds',
      build: () {
        when(() => mockRepository.getHistory(limit: any(named: 'limit')))
            .thenAnswer(
          (_) async => ApiResponse.success(data: mockReadings),
        );
        return BloodPressureCubit(bloodPressureRepository: mockRepository);
      },
      act: (cubit) => cubit.loadHistory(),
      expect: () => [
        const BloodPressureState.loading(),
        BloodPressureState.loaded(mockReadings),
      ],
    );

    blocTest<BloodPressureCubit, BloodPressureState>(
      'emits [loading, failure] when loadHistory fails',
      build: () {
        when(() => mockRepository.getHistory(limit: any(named: 'limit')))
            .thenAnswer(
          (_) async => const ApiResponse.error(message: 'Network error'),
        );
        return BloodPressureCubit(bloodPressureRepository: mockRepository);
      },
      act: (cubit) => cubit.loadHistory(),
      expect: () => [
        const BloodPressureState.loading(),
        const BloodPressureState.failure('Network error'),
      ],
    );

    blocTest<BloodPressureCubit, BloodPressureState>(
      'emits [saving, saved] when saveReading succeeds',
      build: () {
        when(
          () => mockRepository.createReading(
            systolic: any(named: 'systolic'),
            diastolic: any(named: 'diastolic'),
            measuredAt: any(named: 'measuredAt'),
          ),
        ).thenAnswer(
          (_) async => ApiResponse.success(data: mockReading),
        );
        return BloodPressureCubit(bloodPressureRepository: mockRepository);
      },
      act: (cubit) => cubit.saveReading(systolic: 120, diastolic: 80),
      expect: () => [
        const BloodPressureState.saving(),
        BloodPressureState.saved(mockReading, [mockReading]),
      ],
    );

    blocTest<BloodPressureCubit, BloodPressureState>(
      'emits [saving, failure] when saveReading fails',
      build: () {
        when(
          () => mockRepository.createReading(
            systolic: any(named: 'systolic'),
            diastolic: any(named: 'diastolic'),
            measuredAt: any(named: 'measuredAt'),
          ),
        ).thenAnswer(
          (_) async => const ApiResponse.error(message: 'Validation error'),
        );
        return BloodPressureCubit(bloodPressureRepository: mockRepository);
      },
      act: (cubit) => cubit.saveReading(systolic: 50, diastolic: 30),
      expect: () => [
        const BloodPressureState.saving(),
        const BloodPressureState.failure('Validation error'),
      ],
    );

    blocTest<BloodPressureCubit, BloodPressureState>(
      'clearSavedState transitions from saved to loaded',
      build: () => BloodPressureCubit(bloodPressureRepository: mockRepository),
      seed: () => BloodPressureState.saved(mockReading, mockReadings),
      act: (cubit) => cubit.clearSavedState(),
      expect: () => [
        BloodPressureState.loaded(mockReadings),
      ],
    );

    blocTest<BloodPressureCubit, BloodPressureState>(
      'saveReading preserves existing readings on success',
      build: () {
        when(
          () => mockRepository.createReading(
            systolic: any(named: 'systolic'),
            diastolic: any(named: 'diastolic'),
            measuredAt: any(named: 'measuredAt'),
          ),
        ).thenAnswer(
          (_) async => ApiResponse.success(
            data: BloodPressureReading(
              id: 3,
              systolic: 125,
              diastolic: 82,
              measuredAt: DateTime(2026, 1, 19, 15),
            ),
          ),
        );
        return BloodPressureCubit(bloodPressureRepository: mockRepository);
      },
      seed: () => BloodPressureState.loaded(mockReadings),
      act: (cubit) => cubit.saveReading(systolic: 125, diastolic: 82),
      expect: () => [
        const BloodPressureState.saving(),
        isA<BloodPressureSaved>()
            .having((s) => s.readings.length, 'readings length', 3),
      ],
    );
  });

  group('BloodPressureState', () {
    test('isLoading returns true for loading state', () {
      const state = BloodPressureState.loading();
      expect(state.isLoading, isTrue);
      expect(state.isSaving, isFalse);
    });

    test('isSaving returns true for saving state', () {
      const state = BloodPressureState.saving();
      expect(state.isSaving, isTrue);
      expect(state.isLoading, isFalse);
    });

    test('readings returns list for loaded state', () {
      final state = BloodPressureState.loaded(mockReadings);
      expect(state.readings, mockReadings);
    });

    test('readings returns list for saved state', () {
      final state = BloodPressureState.saved(mockReading, mockReadings);
      expect(state.readings, mockReadings);
    });

    test('readings returns empty list for initial state', () {
      const state = BloodPressureState.initial();
      expect(state.readings, isEmpty);
    });
  });
}
