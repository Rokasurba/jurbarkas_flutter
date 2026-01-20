import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/blood_sugar/cubit/blood_sugar_cubit.dart';
import 'package:frontend/blood_sugar/data/models/blood_sugar_reading.dart';
import 'package:frontend/blood_sugar/data/repositories/blood_sugar_repository.dart';
import 'package:frontend/core/data/api_response.dart';
import 'package:frontend/core/data/query_params.dart';
import 'package:mocktail/mocktail.dart';

class MockBloodSugarRepository extends Mock implements BloodSugarRepository {}

class FakePaginationParams extends Fake implements PaginationParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakePaginationParams());
    registerFallbackValue(DateTime(2026));
  });
  late MockBloodSugarRepository mockRepository;

  final mockReading = BloodSugarReading(
    id: 1,
    glucoseLevel: 5.50,
    measuredAt: DateTime(2026, 1, 20, 14, 30),
  );

  final mockReadings = [
    mockReading,
    BloodSugarReading(
      id: 2,
      glucoseLevel: 6.20,
      measuredAt: DateTime(2026, 1, 19, 10),
    ),
  ];

  setUp(() {
    mockRepository = MockBloodSugarRepository();
  });

  group('BloodSugarCubit', () {
    test('initial state is BloodSugarInitial', () {
      final cubit = BloodSugarCubit(bloodSugarRepository: mockRepository);
      expect(cubit.state, const BloodSugarState.initial());
      cubit.close();
    });

    blocTest<BloodSugarCubit, BloodSugarState>(
      'emits [loading, loaded] when loadHistory succeeds',
      build: () {
        when(
          () => mockRepository.getHistory(params: any(named: 'params')),
        ).thenAnswer(
          (_) async => ApiResponse.success(data: mockReadings),
        );
        return BloodSugarCubit(bloodSugarRepository: mockRepository);
      },
      act: (cubit) => cubit.loadHistory(),
      expect: () => [
        const BloodSugarState.loading(),
        BloodSugarState.loaded(mockReadings, hasMore: false),
      ],
    );

    blocTest<BloodSugarCubit, BloodSugarState>(
      'emits [loading, failure] when loadHistory fails',
      build: () {
        when(
          () => mockRepository.getHistory(params: any(named: 'params')),
        ).thenAnswer(
          (_) async => const ApiResponse.error(message: 'Network error'),
        );
        return BloodSugarCubit(bloodSugarRepository: mockRepository);
      },
      act: (cubit) => cubit.loadHistory(),
      expect: () => [
        const BloodSugarState.loading(),
        const BloodSugarState.failure('Network error'),
      ],
    );

    blocTest<BloodSugarCubit, BloodSugarState>(
      'emits [saving, saved] when saveReading succeeds',
      build: () {
        when(
          () => mockRepository.createReading(
            glucoseLevel: any(named: 'glucoseLevel'),
            measuredAt: any(named: 'measuredAt'),
          ),
        ).thenAnswer(
          (_) async => ApiResponse.success(data: mockReading),
        );
        return BloodSugarCubit(bloodSugarRepository: mockRepository);
      },
      act: (cubit) => cubit.saveReading(
        glucoseLevel: 5.5,
        measuredAt: DateTime(2026, 1, 20, 14, 30),
      ),
      expect: () => [
        const BloodSugarState.saving([]),
        BloodSugarState.saved(mockReading, [mockReading]),
      ],
    );

    blocTest<BloodSugarCubit, BloodSugarState>(
      'emits [saving, failure, loaded] when saveReading fails',
      build: () {
        when(
          () => mockRepository.createReading(
            glucoseLevel: any(named: 'glucoseLevel'),
            measuredAt: any(named: 'measuredAt'),
          ),
        ).thenAnswer(
          (_) async => const ApiResponse.error(message: 'Validation error'),
        );
        return BloodSugarCubit(bloodSugarRepository: mockRepository);
      },
      act: (cubit) => cubit.saveReading(
        glucoseLevel: 0.5,
        measuredAt: DateTime(2026, 1, 20),
      ),
      expect: () => [
        const BloodSugarState.saving([]),
        const BloodSugarState.failure('Validation error'),
        // Cubit restores to loaded state after failure
        const BloodSugarState.loaded([], hasMore: false),
      ],
    );

    blocTest<BloodSugarCubit, BloodSugarState>(
      'clearSavedState transitions from saved to loaded with correct hasMore',
      build: () => BloodSugarCubit(bloodSugarRepository: mockRepository),
      seed: () => BloodSugarState.saved(mockReading, mockReadings),
      act: (cubit) => cubit.clearSavedState(),
      expect: () => [
        // hasMore is false because 2 readings < defaultPageSize (20)
        BloodSugarState.loaded(mockReadings, hasMore: false),
      ],
    );

    blocTest<BloodSugarCubit, BloodSugarState>(
      'saveReading preserves existing readings on success',
      build: () {
        when(
          () => mockRepository.createReading(
            glucoseLevel: any(named: 'glucoseLevel'),
            measuredAt: any(named: 'measuredAt'),
          ),
        ).thenAnswer(
          (_) async => ApiResponse.success(
            data: BloodSugarReading(
              id: 3,
              glucoseLevel: 7.10,
              measuredAt: DateTime(2026, 1, 20, 15),
            ),
          ),
        );
        return BloodSugarCubit(bloodSugarRepository: mockRepository);
      },
      seed: () => BloodSugarState.loaded(mockReadings),
      act: (cubit) => cubit.saveReading(
        glucoseLevel: 7.1,
        measuredAt: DateTime(2026, 1, 20, 15),
      ),
      expect: () => [
        BloodSugarState.saving(mockReadings),
        isA<BloodSugarSaved>().having(
          (s) => s.readings.length,
          'readings length',
          3,
        ),
      ],
    );

    blocTest<BloodSugarCubit, BloodSugarState>(
      'loadMore appends new readings',
      build: () {
        when(
          () => mockRepository.getHistory(params: any(named: 'params')),
        ).thenAnswer(
          (_) async => ApiResponse.success(
            data: [
              BloodSugarReading(
                id: 3,
                glucoseLevel: 5.80,
                measuredAt: DateTime(2026, 1, 18, 10),
              ),
            ],
          ),
        );
        return BloodSugarCubit(bloodSugarRepository: mockRepository);
      },
      seed: () => BloodSugarState.loaded(mockReadings),
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        BloodSugarState.loadingMore(mockReadings),
        isA<BloodSugarLoaded>()
            .having((s) => s.readings.length, 'readings length', 3)
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );

    blocTest<BloodSugarCubit, BloodSugarState>(
      'loadMore does nothing when hasMore is false',
      build: () => BloodSugarCubit(bloodSugarRepository: mockRepository),
      seed: () => BloodSugarState.loaded(mockReadings, hasMore: false),
      act: (cubit) => cubit.loadMore(),
      expect: () => <BloodSugarState>[],
    );
  });

  group('BloodSugarState', () {
    test('isLoading returns true for loading state', () {
      const state = BloodSugarState.loading();
      expect(state.isLoading, isTrue);
      expect(state.isSaving, isFalse);
    });

    test('isSaving returns true for saving state', () {
      const state = BloodSugarState.saving([]);
      expect(state.isSaving, isTrue);
      expect(state.isLoading, isFalse);
    });

    test('isLoadingMore returns true for loadingMore state', () {
      const state = BloodSugarState.loadingMore([]);
      expect(state.isLoadingMore, isTrue);
      expect(state.isLoading, isFalse);
    });

    test('hasMore returns true for loaded state with hasMore', () {
      final state = BloodSugarState.loaded(mockReadings);
      expect(state.hasMore, isTrue);
    });

    test('hasMore returns false by default for other states', () {
      const state = BloodSugarState.initial();
      expect(state.hasMore, isFalse);
    });

    test('readings returns list for loaded state', () {
      final state = BloodSugarState.loaded(mockReadings);
      expect(state.readings, mockReadings);
    });

    test('readings returns list for loadingMore state', () {
      final state = BloodSugarState.loadingMore(mockReadings);
      expect(state.readings, mockReadings);
    });

    test('readings returns list for saved state', () {
      final state = BloodSugarState.saved(mockReading, mockReadings);
      expect(state.readings, mockReadings);
    });

    test('readings returns empty list for initial state', () {
      const state = BloodSugarState.initial();
      expect(state.readings, isEmpty);
    });
  });
}
