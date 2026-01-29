import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/blood_pressure/cubit/blood_pressure_cubit.dart';
import 'package:frontend/blood_pressure/data/models/blood_pressure_reading.dart';
import 'package:frontend/blood_pressure/data/repositories/blood_pressure_repository.dart';
import 'package:frontend/core/data/api_response.dart';
import 'package:frontend/core/data/query_params.dart';
import 'package:mocktail/mocktail.dart';

class MockBloodPressureRepository extends Mock
    implements BloodPressureRepository {}

class FakeHealthDataParams extends Fake implements HealthDataParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeHealthDataParams());
    registerFallbackValue(DateTime(2026));
  });
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
        when(() => mockRepository.getHistory(params: any(named: 'params')))
            .thenAnswer(
          (_) async => ApiResponse.success(data: mockReadings),
        );
        return BloodPressureCubit(bloodPressureRepository: mockRepository);
      },
      act: (cubit) => cubit.loadHistory(),
      expect: () => [
        const BloodPressureState.loading(),
        BloodPressureState.loaded(mockReadings, hasMore: false),
      ],
    );

    blocTest<BloodPressureCubit, BloodPressureState>(
      'emits [loading, failure] when loadHistory fails',
      build: () {
        when(() => mockRepository.getHistory(params: any(named: 'params')))
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
      act: (cubit) => cubit.saveReading(
        systolic: 120,
        diastolic: 80,
        measuredAt: DateTime(2026, 1, 19, 14, 30),
      ),
      expect: () => [
        const BloodPressureState.saving([]),
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
      act: (cubit) => cubit.saveReading(
        systolic: 50,
        diastolic: 30,
        measuredAt: DateTime(2026, 1, 19),
      ),
      expect: () => [
        const BloodPressureState.saving([]),
        const BloodPressureState.failure('Validation error'),
        // Cubit restores to loaded state after failure
        const BloodPressureState.loaded([], hasMore: false),
      ],
    );

    blocTest<BloodPressureCubit, BloodPressureState>(
      'clearSavedState transitions from saved to loaded with correct hasMore',
      build: () => BloodPressureCubit(bloodPressureRepository: mockRepository),
      seed: () => BloodPressureState.saved(mockReading, mockReadings),
      act: (cubit) => cubit.clearSavedState(),
      expect: () => [
        // hasMore is false because 2 readings < defaultPageSize (20)
        BloodPressureState.loaded(mockReadings, hasMore: false),
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
      act: (cubit) => cubit.saveReading(
        systolic: 125,
        diastolic: 82,
        measuredAt: DateTime(2026, 1, 19, 15),
      ),
      expect: () => [
        BloodPressureState.saving(mockReadings),
        isA<BloodPressureSaved>()
            .having((s) => s.readings.length, 'readings length', 3),
      ],
    );

    blocTest<BloodPressureCubit, BloodPressureState>(
      'loadMore appends new readings',
      build: () {
        when(() => mockRepository.getHistory(params: any(named: 'params')))
            .thenAnswer(
          (_) async => ApiResponse.success(
            data: [
              BloodPressureReading(
                id: 3,
                systolic: 118,
                diastolic: 78,
                measuredAt: DateTime(2026, 1, 17, 10),
              ),
            ],
          ),
        );
        return BloodPressureCubit(bloodPressureRepository: mockRepository);
      },
      seed: () => BloodPressureState.loaded(mockReadings),
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        BloodPressureState.loadingMore(mockReadings),
        isA<BloodPressureLoaded>()
            .having((s) => s.readings.length, 'readings length', 3)
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );

    blocTest<BloodPressureCubit, BloodPressureState>(
      'loadMore does nothing when hasMore is false',
      build: () => BloodPressureCubit(bloodPressureRepository: mockRepository),
      seed: () => BloodPressureState.loaded(mockReadings, hasMore: false),
      act: (cubit) => cubit.loadMore(),
      expect: () => [],
    );

    group('date filtering', () {
      blocTest<BloodPressureCubit, BloodPressureState>(
        'loadHistory with fromDate sets currentFromDate and disables pagination',
        build: () {
          when(() => mockRepository.getHistory(params: any(named: 'params')))
              .thenAnswer(
            (_) async => ApiResponse.success(data: mockReadings),
          );
          return BloodPressureCubit(bloodPressureRepository: mockRepository);
        },
        act: (cubit) async {
          final fromDate = DateTime(2026);
          await cubit.loadHistory(fromDate: fromDate);
          // Verify the cubit tracks the filter
          expect(cubit.currentFromDate, fromDate);
        },
        expect: () => [
          const BloodPressureState.loading(),
          // hasMore is always false when filtering by date
          BloodPressureState.loaded(mockReadings, hasMore: false),
        ],
      );

      blocTest<BloodPressureCubit, BloodPressureState>(
        'loadHistory without fromDate clears currentFromDate',
        build: () {
          when(() => mockRepository.getHistory(params: any(named: 'params')))
              .thenAnswer(
            (_) async => ApiResponse.success(data: mockReadings),
          );
          return BloodPressureCubit(bloodPressureRepository: mockRepository);
        },
        act: (cubit) async {
          // First load with filter
          await cubit.loadHistory(fromDate: DateTime(2026));
          // Then load without filter
          await cubit.loadHistory();
          expect(cubit.currentFromDate, isNull);
        },
        expect: () => [
          const BloodPressureState.loading(),
          BloodPressureState.loaded(mockReadings, hasMore: false),
          const BloodPressureState.loading(),
          // Without filter, hasMore depends on page size
          BloodPressureState.loaded(mockReadings, hasMore: false),
        ],
      );

      blocTest<BloodPressureCubit, BloodPressureState>(
        'loadMore does nothing when date filter is applied',
        build: () {
          when(() => mockRepository.getHistory(params: any(named: 'params')))
              .thenAnswer(
            (_) async => ApiResponse.success(data: mockReadings),
          );
          return BloodPressureCubit(bloodPressureRepository: mockRepository);
        },
        act: (cubit) async {
          // Load with date filter
          await cubit.loadHistory(fromDate: DateTime(2026));
          // Try to load more - should do nothing
          await cubit.loadMore();
        },
        expect: () => [
          const BloodPressureState.loading(),
          BloodPressureState.loaded(mockReadings, hasMore: false),
          // No additional states from loadMore
        ],
        verify: (cubit) {
          // Repository should only be called once (for loadHistory)
          verify(
            () => mockRepository.getHistory(params: any(named: 'params')),
          ).called(1);
        },
      );

      blocTest<BloodPressureCubit, BloodPressureState>(
        'switching between date filters replaces data',
        build: () {
          final weekReadings = [mockReadings.first];
          final monthReadings = mockReadings;

          var callCount = 0;
          when(() => mockRepository.getHistory(params: any(named: 'params')))
              .thenAnswer((_) async {
            callCount++;
            // First call returns week data, second returns month data
            return ApiResponse.success(
              data: callCount == 1 ? weekReadings : monthReadings,
            );
          });
          return BloodPressureCubit(bloodPressureRepository: mockRepository);
        },
        act: (cubit) async {
          // Load week filter (7 days)
          await cubit.loadHistory(
            fromDate: DateTime.now().subtract(const Duration(days: 7)),
          );
          // Switch to month filter (30 days)
          await cubit.loadHistory(
            fromDate: DateTime.now().subtract(const Duration(days: 30)),
          );
        },
        expect: () => [
          const BloodPressureState.loading(),
          BloodPressureState.loaded([mockReadings.first], hasMore: false),
          const BloodPressureState.loading(),
          BloodPressureState.loaded(mockReadings, hasMore: false),
        ],
      );
    });
  });

  group('BloodPressureState', () {
    test('isLoading returns true for loading state', () {
      const state = BloodPressureState.loading();
      expect(state.isLoading, isTrue);
      expect(state.isSaving, isFalse);
    });

    test('isSaving returns true for saving state', () {
      const state = BloodPressureState.saving([]);
      expect(state.isSaving, isTrue);
      expect(state.isLoading, isFalse);
    });

    test('isLoadingMore returns true for loadingMore state', () {
      const state = BloodPressureState.loadingMore([]);
      expect(state.isLoadingMore, isTrue);
      expect(state.isLoading, isFalse);
    });

    test('hasMore returns true for loaded state with hasMore', () {
      final state = BloodPressureState.loaded(mockReadings);
      expect(state.hasMore, isTrue);
    });

    test('hasMore returns false by default for other states', () {
      const state = BloodPressureState.initial();
      expect(state.hasMore, isFalse);
    });

    test('readings returns list for loaded state', () {
      final state = BloodPressureState.loaded(mockReadings);
      expect(state.readings, mockReadings);
    });

    test('readings returns list for loadingMore state', () {
      final state = BloodPressureState.loadingMore(mockReadings);
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
