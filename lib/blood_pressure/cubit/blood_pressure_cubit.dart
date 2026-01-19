import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/blood_pressure/data/models/blood_pressure_reading.dart';
import 'package:frontend/blood_pressure/data/repositories/blood_pressure_repository.dart';

part 'blood_pressure_state.dart';
part 'blood_pressure_cubit.freezed.dart';

class BloodPressureCubit extends Cubit<BloodPressureState> {
  BloodPressureCubit({
    required BloodPressureRepository bloodPressureRepository,
  })  : _bloodPressureRepository = bloodPressureRepository,
        super(const BloodPressureState.initial());

  final BloodPressureRepository _bloodPressureRepository;

  Future<void> loadHistory({int? limit}) async {
    emit(const BloodPressureState.loading());

    final response = await _bloodPressureRepository.getHistory(limit: limit);

    response.when(
      success: (readings, _) => emit(BloodPressureState.loaded(readings)),
      error: (message, _) => emit(BloodPressureState.failure(message)),
    );
  }

  Future<void> saveReading({
    required int systolic,
    required int diastolic,
  }) async {
    // Keep current readings if we have them
    final currentReadings = state.maybeWhen(
      loaded: (readings) => readings,
      orElse: () => <BloodPressureReading>[],
    );

    emit(const BloodPressureState.saving());

    final response = await _bloodPressureRepository.createReading(
      systolic: systolic,
      diastolic: diastolic,
    );

    response.when(
      success: (reading, _) {
        // Add the new reading to the beginning of the list
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
