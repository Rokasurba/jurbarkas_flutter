import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/bmi/data/models/bmi_measurement.dart';
import 'package:frontend/bmi/data/repositories/bmi_repository.dart';
import 'package:frontend/core/data/query_params.dart';

part 'bmi_state.dart';
part 'bmi_cubit.freezed.dart';

class BmiCubit extends Cubit<BmiState> {
  BmiCubit({
    required BmiRepository bmiRepository,
  })  : _bmiRepository = bmiRepository,
        super(const BmiState.initial());

  final BmiRepository _bmiRepository;

  Future<void> loadHistory() async {
    emit(const BmiState.loading());

    final response = await _bmiRepository.getHistory(
      params: const PaginationParams.firstPage(),
    );

    response.when(
      success: (measurements, _) {
        final hasMore = measurements.length >= PaginationParams.defaultPageSize;
        emit(BmiState.loaded(measurements, hasMore: hasMore));
      },
      error: (message, _) => emit(BmiState.failure(message)),
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    final currentMeasurements = state.measurements;
    emit(BmiState.loadingMore(currentMeasurements));

    final response = await _bmiRepository.getHistory(
      params: PaginationParams.nextPage(currentMeasurements.length),
    );

    response.when(
      success: (newMeasurements, _) {
        final allMeasurements = [...currentMeasurements, ...newMeasurements];
        final hasMore =
            newMeasurements.length >= PaginationParams.defaultPageSize;
        emit(BmiState.loaded(allMeasurements, hasMore: hasMore));
      },
      error: (message, _) => emit(BmiState.failure(message)),
    );
  }

  Future<void> saveMeasurement({
    required int heightCm,
    required double weightKg,
  }) async {
    final currentMeasurements = state.measurements;

    emit(BmiState.saving(currentMeasurements));

    final response = await _bmiRepository.createMeasurement(
      heightCm: heightCm,
      weightKg: weightKg,
    );

    response.when(
      success: (measurement, _) {
        final updatedMeasurements = [measurement, ...currentMeasurements];
        emit(BmiState.saved(measurement, updatedMeasurements));
      },
      error: (message, _) => emit(BmiState.failure(message)),
    );
  }

  Future<void> updateMeasurement({
    required int id,
    required int heightCm,
    required double weightKg,
  }) async {
    final currentMeasurements = state.measurements;

    emit(BmiState.updating(currentMeasurements));

    final response = await _bmiRepository.updateMeasurement(
      id: id,
      heightCm: heightCm,
      weightKg: weightKg,
    );

    response.when(
      success: (updatedMeasurement, _) {
        final updatedMeasurements = currentMeasurements.map((measurement) {
          return measurement.id == id ? updatedMeasurement : measurement;
        }).toList();
        emit(BmiState.updated(updatedMeasurement, updatedMeasurements));
      },
      error: (message, _) => emit(BmiState.failure(message)),
    );
  }

  Future<void> deleteMeasurement({required int id}) async {
    final currentMeasurements = state.measurements;

    emit(BmiState.deleting(currentMeasurements));

    final response = await _bmiRepository.deleteMeasurement(id: id);

    response.when(
      success: (_, __) {
        final updatedMeasurements = currentMeasurements
            .where((measurement) => measurement.id != id)
            .toList();
        emit(BmiState.deleted(updatedMeasurements));
      },
      error: (message, _) => emit(BmiState.failure(message)),
    );
  }

  void clearSavedState() {
    state.maybeWhen(
      saved: (_, measurements) {
        // Preserve hasMore based on whether we had a full page of measurements
        final hasMore = measurements.length >= PaginationParams.defaultPageSize;
        emit(BmiState.loaded(measurements, hasMore: hasMore));
      },
      orElse: () {
        emit(const BmiState.initial());
      },
    );
  }

  void clearUpdatedState() {
    state.maybeWhen(
      updated: (_, measurements) {
        final hasMore = measurements.length >= PaginationParams.defaultPageSize;
        emit(BmiState.loaded(measurements, hasMore: hasMore));
      },
      orElse: () {
        emit(const BmiState.initial());
      },
    );
  }

  void clearDeletedState() {
    state.maybeWhen(
      deleted: (measurements) {
        final hasMore = measurements.length >= PaginationParams.defaultPageSize;
        emit(BmiState.loaded(measurements, hasMore: hasMore));
      },
      orElse: () {
        emit(const BmiState.initial());
      },
    );
  }
}
