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
  DateTime? _currentFromDate;

  /// Current date filter being applied
  DateTime? get currentFromDate => _currentFromDate;

  Future<void> loadHistory({DateTime? fromDate}) async {
    _currentFromDate = fromDate;
    emit(const BloodPressureState.loading());

    final params = fromDate != null
        ? HealthDataParams.withDateFilter(fromDate)
        : const HealthDataParams.firstPage();

    final response = await _bloodPressureRepository.getHistory(params: params);

    response.when(
      success: (readings, _) {
        // When filtering by date, we don't support pagination (all data fetched)
        // When no filter, we support pagination
        final hasMore = fromDate == null &&
            readings.length >= HealthDataParams.defaultPageSize;
        emit(BloodPressureState.loaded(readings, hasMore: hasMore));
      },
      error: (message, _) => emit(BloodPressureState.failure(message)),
    );
  }

  Future<void> loadMore() async {
    // Don't allow load more when a date filter is applied
    if (state.isLoadingMore || !state.hasMore || _currentFromDate != null) {
      return;
    }

    final currentReadings = state.readings;
    emit(BloodPressureState.loadingMore(currentReadings));

    final response = await _bloodPressureRepository.getHistory(
      params: HealthDataParams.nextPage(currentReadings.length),
    );

    response.when(
      success: (newReadings, _) {
        final allReadings = [...currentReadings, ...newReadings];
        final hasMore = newReadings.length >= HealthDataParams.defaultPageSize;
        emit(BloodPressureState.loaded(allReadings, hasMore: hasMore));
      },
      error: (message, _) => emit(BloodPressureState.failure(message)),
    );
  }

  Future<void> saveReading({
    required int systolic,
    required int diastolic,
    required DateTime measuredAt,
  }) async {
    final currentReadings = state.readings;
    final currentHasMore = state.hasMore;

    emit(BloodPressureState.saving(currentReadings));

    final response = await _bloodPressureRepository.createReading(
      systolic: systolic,
      diastolic: diastolic,
      measuredAt: measuredAt,
    );

    response.when(
      success: (reading, _) {
        final updatedReadings = [reading, ...currentReadings];
        // Emit saved - listeners will show snackbar and clear form
        // Then call clearSavedState() to transition to loaded
        emit(BloodPressureState.saved(reading, updatedReadings));
      },
      error: (message, _) {
        // On error, show failure then restore to loaded state with original data
        emit(BloodPressureState.failure(message));
        emit(BloodPressureState.loaded(currentReadings, hasMore: currentHasMore));
      },
    );
  }

  Future<void> deleteReading({required int id}) async {
    final currentReadings = state.readings;
    final currentHasMore = state.hasMore;

    emit(BloodPressureState.deleting(currentReadings));

    final response = await _bloodPressureRepository.deleteReading(id: id);

    response.when(
      success: (_, _) {
        final updatedReadings =
            currentReadings.where((reading) => reading.id != id).toList();
        // First emit deleted for the listener to show snackbar
        emit(BloodPressureState.deleted(updatedReadings));
        // Then immediately emit loaded to preserve the state
        emit(BloodPressureState.loaded(updatedReadings, hasMore: currentHasMore));
      },
      error: (message, _) {
        // On error, show failure then restore to loaded state with original data
        emit(BloodPressureState.failure(message));
        emit(BloodPressureState.loaded(currentReadings, hasMore: currentHasMore));
      },
    );
  }

  void clearSavedState() {
    state.maybeWhen(
      saved: (_, readings) {
        // When filtering, hasMore is false; otherwise based on page size
        final hasMore = _currentFromDate == null &&
            readings.length >= HealthDataParams.defaultPageSize;
        emit(BloodPressureState.loaded(readings, hasMore: hasMore));
      },
      orElse: () {
        emit(const BloodPressureState.initial());
      },
    );
  }

  void clearDeletedState() {
    // Always preserve current readings when clearing deleted state
    final currentReadings = state.readings;
    final hasMore = _currentFromDate == null &&
        currentReadings.length >= HealthDataParams.defaultPageSize;
    emit(BloodPressureState.loaded(currentReadings, hasMore: hasMore));
  }
}
