import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/bmi/cubit/bmi_cubit.dart';
import 'package:frontend/bmi/data/models/bmi_measurement.dart';
import 'package:frontend/bmi/data/repositories/bmi_repository.dart';
import 'package:frontend/core/data/api_response.dart';
import 'package:frontend/core/data/query_params.dart';
import 'package:mocktail/mocktail.dart';

class MockBmiRepository extends Mock implements BmiRepository {}

class FakeHealthDataParams extends Fake implements HealthDataParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeHealthDataParams());
    registerFallbackValue(DateTime(2026));
  });
  late MockBmiRepository mockRepository;

  final mockMeasurement = BmiMeasurement(
    id: 1,
    heightCm: 175,
    weightKg: 70,
    bmiValue: 22.86,
    measuredAt: DateTime(2026, 1, 19, 14, 30),
  );

  final mockMeasurements = [
    mockMeasurement,
    BmiMeasurement(
      id: 2,
      heightCm: 175,
      weightKg: 72,
      bmiValue: 23.51,
      measuredAt: DateTime(2026, 1, 18, 10),
    ),
  ];

  setUp(() {
    mockRepository = MockBmiRepository();
  });

  group('BmiCubit', () {
    test('initial state is BmiInitial', () {
      final cubit = BmiCubit(bmiRepository: mockRepository);
      expect(cubit.state, const BmiState.initial());
      cubit.close();
    });

    blocTest<BmiCubit, BmiState>(
      'emits [loading, loaded] when loadHistory succeeds',
      build: () {
        when(() => mockRepository.getHistory(params: any(named: 'params')))
            .thenAnswer(
          (_) async => ApiResponse.success(data: mockMeasurements),
        );
        return BmiCubit(bmiRepository: mockRepository);
      },
      act: (cubit) => cubit.loadHistory(),
      expect: () => [
        const BmiState.loading(),
        BmiState.loaded(mockMeasurements, hasMore: false),
      ],
    );

    blocTest<BmiCubit, BmiState>(
      'emits [loading, failure] when loadHistory fails',
      build: () {
        when(() => mockRepository.getHistory(params: any(named: 'params')))
            .thenAnswer(
          (_) async => const ApiResponse.error(message: 'Network error'),
        );
        return BmiCubit(bmiRepository: mockRepository);
      },
      act: (cubit) => cubit.loadHistory(),
      expect: () => [
        const BmiState.loading(),
        const BmiState.failure('Network error'),
      ],
    );

    blocTest<BmiCubit, BmiState>(
      'emits [saving, saved] when saveMeasurement succeeds',
      build: () {
        when(
          () => mockRepository.createMeasurement(
            heightCm: any(named: 'heightCm'),
            weightKg: any(named: 'weightKg'),
            measuredAt: any(named: 'measuredAt'),
          ),
        ).thenAnswer(
          (_) async => ApiResponse.success(data: mockMeasurement),
        );
        return BmiCubit(bmiRepository: mockRepository);
      },
      act: (cubit) => cubit.saveMeasurement(
        heightCm: 175,
        weightKg: 70,
        measuredAt: DateTime(2026, 1, 19, 14, 30),
      ),
      expect: () => [
        const BmiState.saving([]),
        BmiState.saved(mockMeasurement, [mockMeasurement]),
      ],
    );

    blocTest<BmiCubit, BmiState>(
      'emits [saving, failure, loaded] when saveMeasurement fails',
      build: () {
        when(
          () => mockRepository.createMeasurement(
            heightCm: any(named: 'heightCm'),
            weightKg: any(named: 'weightKg'),
            measuredAt: any(named: 'measuredAt'),
          ),
        ).thenAnswer(
          (_) async => const ApiResponse.error(message: 'Validation error'),
        );
        return BmiCubit(bmiRepository: mockRepository);
      },
      act: (cubit) => cubit.saveMeasurement(
        heightCm: 30,
        weightKg: 10,
        measuredAt: DateTime(2026, 1, 19),
      ),
      expect: () => [
        const BmiState.saving([]),
        const BmiState.failure('Validation error'),
        // Cubit restores to loaded state after failure
        const BmiState.loaded([], hasMore: false),
      ],
    );

    blocTest<BmiCubit, BmiState>(
      'clearSavedState transitions from saved to loaded with correct hasMore',
      build: () => BmiCubit(bmiRepository: mockRepository),
      seed: () => BmiState.saved(mockMeasurement, mockMeasurements),
      act: (cubit) => cubit.clearSavedState(),
      expect: () => [
        // hasMore is false because 2 measurements < defaultPageSize (20)
        BmiState.loaded(mockMeasurements, hasMore: false),
      ],
    );

    blocTest<BmiCubit, BmiState>(
      'saveMeasurement preserves existing measurements on success',
      build: () {
        when(
          () => mockRepository.createMeasurement(
            heightCm: any(named: 'heightCm'),
            weightKg: any(named: 'weightKg'),
            measuredAt: any(named: 'measuredAt'),
          ),
        ).thenAnswer(
          (_) async => ApiResponse.success(
            data: BmiMeasurement(
              id: 3,
              heightCm: 175,
              weightKg: 71,
              bmiValue: 23.18,
              measuredAt: DateTime(2026, 1, 19, 15),
            ),
          ),
        );
        return BmiCubit(bmiRepository: mockRepository);
      },
      seed: () => BmiState.loaded(mockMeasurements),
      act: (cubit) => cubit.saveMeasurement(
        heightCm: 175,
        weightKg: 71,
        measuredAt: DateTime(2026, 1, 19, 15),
      ),
      expect: () => [
        BmiState.saving(mockMeasurements),
        isA<BmiSaved>()
            .having((s) => s.measurements.length, 'measurements length', 3),
      ],
    );

    blocTest<BmiCubit, BmiState>(
      'loadMore appends new measurements',
      build: () {
        when(() => mockRepository.getHistory(params: any(named: 'params')))
            .thenAnswer(
          (_) async => ApiResponse.success(
            data: [
              BmiMeasurement(
                id: 3,
                heightCm: 175,
                weightKg: 68,
                bmiValue: 22.20,
                measuredAt: DateTime(2026, 1, 17, 10),
              ),
            ],
          ),
        );
        return BmiCubit(bmiRepository: mockRepository);
      },
      seed: () => BmiState.loaded(mockMeasurements),
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        BmiState.loadingMore(mockMeasurements),
        isA<BmiLoaded>()
            .having((s) => s.measurements.length, 'measurements length', 3)
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );

    blocTest<BmiCubit, BmiState>(
      'loadMore does nothing when hasMore is false',
      build: () => BmiCubit(bmiRepository: mockRepository),
      seed: () => BmiState.loaded(mockMeasurements, hasMore: false),
      act: (cubit) => cubit.loadMore(),
      expect: () => [],
    );

    group('date filtering', () {
      blocTest<BmiCubit, BmiState>(
        'loadHistory with fromDate sets currentFromDate and disables pagination',
        build: () {
          when(() => mockRepository.getHistory(params: any(named: 'params')))
              .thenAnswer(
            (_) async => ApiResponse.success(data: mockMeasurements),
          );
          return BmiCubit(bmiRepository: mockRepository);
        },
        act: (cubit) async {
          final fromDate = DateTime(2026, 1);
          await cubit.loadHistory(fromDate: fromDate);
          // Verify the cubit tracks the filter
          expect(cubit.currentFromDate, fromDate);
        },
        expect: () => [
          const BmiState.loading(),
          // hasMore is always false when filtering by date
          BmiState.loaded(mockMeasurements, hasMore: false),
        ],
      );

      blocTest<BmiCubit, BmiState>(
        'loadHistory without fromDate clears currentFromDate',
        build: () {
          when(() => mockRepository.getHistory(params: any(named: 'params')))
              .thenAnswer(
            (_) async => ApiResponse.success(data: mockMeasurements),
          );
          return BmiCubit(bmiRepository: mockRepository);
        },
        act: (cubit) async {
          // First load with filter
          await cubit.loadHistory(fromDate: DateTime(2026, 1));
          // Then load without filter
          await cubit.loadHistory();
          expect(cubit.currentFromDate, isNull);
        },
        expect: () => [
          const BmiState.loading(),
          BmiState.loaded(mockMeasurements, hasMore: false),
          const BmiState.loading(),
          // Without filter, hasMore depends on page size
          BmiState.loaded(mockMeasurements, hasMore: false),
        ],
      );

      blocTest<BmiCubit, BmiState>(
        'loadMore does nothing when date filter is applied',
        build: () {
          when(() => mockRepository.getHistory(params: any(named: 'params')))
              .thenAnswer(
            (_) async => ApiResponse.success(data: mockMeasurements),
          );
          return BmiCubit(bmiRepository: mockRepository);
        },
        act: (cubit) async {
          // Load with date filter
          await cubit.loadHistory(fromDate: DateTime(2026, 1));
          // Try to load more - should do nothing
          await cubit.loadMore();
        },
        expect: () => [
          const BmiState.loading(),
          BmiState.loaded(mockMeasurements, hasMore: false),
          // No additional states from loadMore
        ],
        verify: (cubit) {
          // Repository should only be called once (for loadHistory)
          verify(
            () => mockRepository.getHistory(params: any(named: 'params')),
          ).called(1);
        },
      );

      blocTest<BmiCubit, BmiState>(
        'switching between date filters replaces data',
        build: () {
          final weekMeasurements = [mockMeasurements.first];
          final monthMeasurements = mockMeasurements;

          var callCount = 0;
          when(() => mockRepository.getHistory(params: any(named: 'params')))
              .thenAnswer((_) async {
            callCount++;
            // First call returns week data, second returns month data
            return ApiResponse.success(
              data: callCount == 1 ? weekMeasurements : monthMeasurements,
            );
          });
          return BmiCubit(bmiRepository: mockRepository);
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
          const BmiState.loading(),
          BmiState.loaded([mockMeasurements.first], hasMore: false),
          const BmiState.loading(),
          BmiState.loaded(mockMeasurements, hasMore: false),
        ],
      );
    });
  });

  group('BmiState', () {
    test('isLoading returns true for loading state', () {
      const state = BmiState.loading();
      expect(state.isLoading, isTrue);
      expect(state.isSaving, isFalse);
    });

    test('isSaving returns true for saving state', () {
      const state = BmiState.saving([]);
      expect(state.isSaving, isTrue);
      expect(state.isLoading, isFalse);
    });

    test('isLoadingMore returns true for loadingMore state', () {
      const state = BmiState.loadingMore([]);
      expect(state.isLoadingMore, isTrue);
      expect(state.isLoading, isFalse);
    });

    test('hasMore returns true for loaded state with hasMore', () {
      final state = BmiState.loaded(mockMeasurements);
      expect(state.hasMore, isTrue);
    });

    test('hasMore returns false by default for other states', () {
      const state = BmiState.initial();
      expect(state.hasMore, isFalse);
    });

    test('measurements returns list for loaded state', () {
      final state = BmiState.loaded(mockMeasurements);
      expect(state.measurements, mockMeasurements);
    });

    test('measurements returns list for loadingMore state', () {
      final state = BmiState.loadingMore(mockMeasurements);
      expect(state.measurements, mockMeasurements);
    });

    test('measurements returns list for saved state', () {
      final state = BmiState.saved(mockMeasurement, mockMeasurements);
      expect(state.measurements, mockMeasurements);
    });

    test('measurements returns empty list for initial state', () {
      const state = BmiState.initial();
      expect(state.measurements, isEmpty);
    });
  });
}
