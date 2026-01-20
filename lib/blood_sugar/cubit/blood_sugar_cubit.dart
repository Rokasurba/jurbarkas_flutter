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

  Future<void> loadHistory() async {
    emit(const BloodSugarState.loading());

    final response = await _bloodSugarRepository.getHistory(
      params: const PaginationParams.firstPage(),
    );

    response.when(
      success: (readings, _) {
        final hasMore = readings.length >= PaginationParams.defaultPageSize;
        emit(BloodSugarState.loaded(readings, hasMore: hasMore));
      },
      error: (message, _) => emit(BloodSugarState.failure(message)),
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    final currentReadings = state.readings;
    emit(BloodSugarState.loadingMore(currentReadings));

    final response = await _bloodSugarRepository.getHistory(
      params: PaginationParams.nextPage(currentReadings.length),
    );

    response.when(
      success: (newReadings, _) {
        final allReadings = [...currentReadings, ...newReadings];
        final hasMore = newReadings.length >= PaginationParams.defaultPageSize;
        emit(BloodSugarState.loaded(allReadings, hasMore: hasMore));
      },
      error: (message, _) => emit(BloodSugarState.failure(message)),
    );
  }

  Future<void> saveReading({
    required double glucoseLevel,
  }) async {
    final currentReadings = state.readings;

    emit(BloodSugarState.saving(currentReadings));

    final response = await _bloodSugarRepository.createReading(
      glucoseLevel: glucoseLevel,
    );

    response.when(
      success: (reading, _) {
        final updatedReadings = [reading, ...currentReadings];
        emit(BloodSugarState.saved(reading, updatedReadings));
      },
      error: (message, _) => emit(BloodSugarState.failure(message)),
    );
  }

  Future<void> updateReading({
    required int id,
    required double glucoseLevel,
  }) async {
    final currentReadings = state.readings;

    emit(BloodSugarState.updating(currentReadings));

    final response = await _bloodSugarRepository.updateReading(
      id: id,
      glucoseLevel: glucoseLevel,
    );

    response.when(
      success: (updatedReading, _) {
        final updatedReadings = currentReadings.map((reading) {
          return reading.id == id ? updatedReading : reading;
        }).toList();
        emit(BloodSugarState.updated(updatedReading, updatedReadings));
      },
      error: (message, _) => emit(BloodSugarState.failure(message)),
    );
  }

  Future<void> deleteReading({required int id}) async {
    final currentReadings = state.readings;

    emit(BloodSugarState.deleting(currentReadings));

    final response = await _bloodSugarRepository.deleteReading(id: id);

    response.when(
      success: (_, __) {
        final updatedReadings =
            currentReadings.where((reading) => reading.id != id).toList();
        emit(BloodSugarState.deleted(updatedReadings));
      },
      error: (message, _) => emit(BloodSugarState.failure(message)),
    );
  }

  void clearSavedState() {
    state.maybeWhen(
      saved: (_, readings) {
        // Preserve hasMore based on whether we had a full page of readings
        final hasMore = readings.length >= PaginationParams.defaultPageSize;
        emit(BloodSugarState.loaded(readings, hasMore: hasMore));
      },
      orElse: () {
        emit(const BloodSugarState.initial());
      },
    );
  }

  void clearUpdatedState() {
    state.maybeWhen(
      updated: (_, readings) {
        final hasMore = readings.length >= PaginationParams.defaultPageSize;
        emit(BloodSugarState.loaded(readings, hasMore: hasMore));
      },
      orElse: () {
        emit(const BloodSugarState.initial());
      },
    );
  }

  void clearDeletedState() {
    state.maybeWhen(
      deleted: (readings) {
        final hasMore = readings.length >= PaginationParams.defaultPageSize;
        emit(BloodSugarState.loaded(readings, hasMore: hasMore));
      },
      orElse: () {
        emit(const BloodSugarState.initial());
      },
    );
  }
}
