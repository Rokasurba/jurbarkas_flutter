import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/bmi/cubit/bmi_cubit.dart';
import 'package:frontend/bmi/data/models/bmi_measurement.dart';
import 'package:frontend/bmi/data/repositories/bmi_repository.dart';
import 'package:frontend/core/data/api_response.dart';
import 'package:frontend/core/data/query_params.dart';
import 'package:mocktail/mocktail.dart';

class MockBmiRepository extends Mock implements BmiRepository {}

class FakePaginationParams extends Fake implements PaginationParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakePaginationParams());
  });
  late MockBmiRepository mockRepository;

  final mockMeasurement = BmiMeasurement(
    id: 1,
    heightCm: 175,
    weightKg: '70.00',
    bmiValue: '22.86',
    measuredAt: DateTime(2026, 1, 19, 14, 30),
  );

  final mockMeasurements = [
    mockMeasurement,
    BmiMeasurement(
      id: 2,
      heightCm: 175,
      weightKg: '72.00',
      bmiValue: '23.51',
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
      act: (cubit) => cubit.saveMeasurement(heightCm: 175, weightKg: 70),
      expect: () => [
        const BmiState.saving([]),
        BmiState.saved(mockMeasurement, [mockMeasurement]),
      ],
    );

    blocTest<BmiCubit, BmiState>(
      'emits [saving, failure] when saveMeasurement fails',
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
      act: (cubit) => cubit.saveMeasurement(heightCm: 30, weightKg: 10),
      expect: () => [
        const BmiState.saving([]),
        const BmiState.failure('Validation error'),
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
              weightKg: '71.00',
              bmiValue: '23.18',
              measuredAt: DateTime(2026, 1, 19, 15),
            ),
          ),
        );
        return BmiCubit(bmiRepository: mockRepository);
      },
      seed: () => BmiState.loaded(mockMeasurements),
      act: (cubit) => cubit.saveMeasurement(heightCm: 175, weightKg: 71),
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
                weightKg: '68.00',
                bmiValue: '22.20',
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
