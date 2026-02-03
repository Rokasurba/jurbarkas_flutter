import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/blood_sugar/data/models/blood_sugar_reading.dart';
import 'package:frontend/blood_sugar/data/repositories/blood_sugar_repository.dart';
import 'package:frontend/core/data/query_params.dart';

part 'blood_sugar_state.dart';
part 'blood_sugar_cubit.freezed.dart';

class BloodSugarCubit extends Cubit<BloodSugarState> {
  BloodSugarCubit({
    required BloodSugarRepository bloodSugarRepository,
  })  : _bloodSugarRepository = bloodSugarRepository,
        super(const BloodSugarState.initial());

  final BloodSugarRepository _bloodSugarRepository;
  DateTime? _currentFromDate;

  /// Current date filter being applied
  DateTime? get currentFromDate => _currentFromDate;

  Future<void> loadHistory({DateTime? fromDate}) async {
    _currentFromDate = fromDate;
    emit(const BloodSugarState.loading());

    final params = fromDate != null
        ? HealthDataParams.withDateFilter(fromDate)
        : const HealthDataParams.firstPage();

    final response = await _bloodSugarRepository.getHistory(params: params);

    response.when(
      success: (readings, _) {
        // When filtering by date, we don't support pagination (all data fetched)
        // When no filter, we support pagination
        final hasMore = fromDate == null &&
            readings.length >= HealthDataParams.defaultPageSize;
        emit(BloodSugarState.loaded(readings, hasMore: hasMore));
      },
      error: (message, _) => emit(BloodSugarState.failure(message)),
    );
  }

  Future<void> loadMore() async {
    // Don't allow load more when a date filter is applied
    if (state.isLoadingMore || !state.hasMore || _currentFromDate != null) {
      return;
    }

    final currentReadings = state.readings;
    emit(BloodSugarState.loadingMore(currentReadings));

    final response = await _bloodSugarRepository.getHistory(
      params: HealthDataParams.nextPage(currentReadings.length),
    );

    response.when(
      success: (newReadings, _) {
        final allReadings = [...currentReadings, ...newReadings];
        final hasMore = newReadings.length >= HealthDataParams.defaultPageSize;
        emit(BloodSugarState.loaded(allReadings, hasMore: hasMore));
      },
      error: (message, _) => emit(BloodSugarState.failure(message)),
    );
  }

  Future<void> saveReading({
    required double glucoseLevel,
    required DateTime measuredAt,
  }) async {
    final currentReadings = state.readings;

    emit(BloodSugarState.saving(currentReadings));

    final response = await _bloodSugarRepository.createReading(
      glucoseLevel: glucoseLevel,
      measuredAt: measuredAt,
    );

    response.when(
      success: (reading, _) {
        final updatedReadings = [reading, ...currentReadings];
        emit(BloodSugarState.saved(reading, updatedReadings));
      },
      error: (message, _) {
        emit(BloodSugarState.failure(message));
        final hasMore = _currentFromDate == null &&
            currentReadings.length >= HealthDataParams.defaultPageSize;
        emit(BloodSugarState.loaded(currentReadings, hasMore: hasMore));
      },
    );
  }

  Future<void> deleteReading({required int id}) async {
    final currentReadings = state.readings;

    emit(BloodSugarState.deleting(currentReadings));

    final response = await _bloodSugarRepository.deleteReading(id: id);

    response.when(
      success: (data, message) {
        final updatedReadings =
            currentReadings.where((reading) => reading.id != id).toList();
        final hasMore = _currentFromDate == null &&
            updatedReadings.length >= HealthDataParams.defaultPageSize;
        // First emit deleted for the listener to show snackbar
        emit(BloodSugarState.deleted(updatedReadings));
        // Then immediately emit loaded to preserve the state
        emit(BloodSugarState.loaded(updatedReadings, hasMore: hasMore));
      },
      error: (message, _) {
        emit(BloodSugarState.failure(message));
        final hasMore = _currentFromDate == null &&
            currentReadings.length >= HealthDataParams.defaultPageSize;
        emit(BloodSugarState.loaded(currentReadings, hasMore: hasMore));
      },
    );
  }

  void clearSavedState() {
    state.maybeWhen(
      saved: (_, readings) {
        // When filtering, hasMore is false; otherwise based on page size
        final hasMore = _currentFromDate == null &&
            readings.length >= HealthDataParams.defaultPageSize;
        emit(BloodSugarState.loaded(readings, hasMore: hasMore));
      },
      orElse: () {
        emit(const BloodSugarState.initial());
      },
    );
  }

  void clearDeletedState() {
    // Always preserve current readings when clearing deleted state
    final currentReadings = state.readings;
    final hasMore = _currentFromDate == null &&
        currentReadings.length >= HealthDataParams.defaultPageSize;
    emit(BloodSugarState.loaded(currentReadings, hasMore: hasMore));
  }
}
