import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/blood_pressure/data/models/blood_pressure_reading.dart';
import 'package:frontend/blood_pressure/data/repositories/blood_pressure_repository.dart';
import 'package:frontend/core/data/query_params.dart';

part 'blood_pressure_state.dart';
part 'blood_pressure_cubit.freezed.dart';

class BloodPressureCubit extends Cubit<BloodPressureState> {
  BloodPressureCubit({
    required BloodPressureRepository bloodPressureRepository,
  })  : _bloodPressureRepository = bloodPressureRepository,
        super(const BloodPressureState.initial());

  final BloodPressureRepository _bloodPressureRepository;

  Future<void> loadHistory() async {
    emit(const BloodPressureState.loading());

    final response = await _bloodPressureRepository.getHistory(
      params: const PaginationParams.firstPage(),
    );

    response.when(
      success: (readings, _) {
        final hasMore = readings.length >= PaginationParams.defaultPageSize;
        emit(BloodPressureState.loaded(readings, hasMore: hasMore));
      },
      error: (message, _) => emit(BloodPressureState.failure(message)),
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    final currentReadings = state.readings;
    emit(BloodPressureState.loadingMore(currentReadings));

    final response = await _bloodPressureRepository.getHistory(
      params: PaginationParams.nextPage(currentReadings.length),
    );

    response.when(
      success: (newReadings, _) {
        final allReadings = [...currentReadings, ...newReadings];
        final hasMore = newReadings.length >= PaginationParams.defaultPageSize;
        emit(BloodPressureState.loaded(allReadings, hasMore: hasMore));
      },
      error: (message, _) => emit(BloodPressureState.failure(message)),
    );
  }

  Future<void> saveReading({
    required int systolic,
    required int diastolic,
  }) async {
    final currentReadings = state.readings;

    emit(BloodPressureState.saving(currentReadings));

    final response = await _bloodPressureRepository.createReading(
      systolic: systolic,
      diastolic: diastolic,
    );

    response.when(
      success: (reading, _) {
        final updatedReadings = [reading, ...currentReadings];
        emit(BloodPressureState.saved(reading, updatedReadings));
      },
      error: (message, _) => emit(BloodPressureState.failure(message)),
    );
  }

  void clearSavedState() {
    final readings = state.maybeWhen(
      saved: (_, readings) => readings,
      orElse: () => <BloodPressureReading>[],
    );
    if (readings.isNotEmpty) {
      emit(BloodPressureState.loaded(readings));
    } else {
      emit(const BloodPressureState.initial());
    }
  }
}
