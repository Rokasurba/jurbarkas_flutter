import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/bmi/data/models/bmi_measurement.dart';
import 'package:frontend/bmi/data/repositories/bmi_repository.dart';

part 'bmi_state.dart';
part 'bmi_cubit.freezed.dart';

class BmiCubit extends Cubit<BmiState> {
  BmiCubit({
    required BmiRepository bmiRepository,
  })  : _bmiRepository = bmiRepository,
        super(const BmiState.initial());

  final BmiRepository _bmiRepository;

  Future<void> loadHistory({int? limit}) async {
    emit(const BmiState.loading());

    final response = await _bmiRepository.getHistory(limit: limit);

    response.when(
      success: (measurements, _) => emit(BmiState.loaded(measurements)),
      error: (message, _) => emit(BmiState.failure(message)),
    );
  }

  Future<void> saveMeasurement({
    required int heightCm,
    required double weightKg,
  }) async {
    // Keep current measurements if we have them
    final currentMeasurements = state.maybeWhen(
      loaded: (measurements) => measurements,
      orElse: () => <BmiMeasurement>[],
    );

    emit(const BmiState.saving());

    final response = await _bmiRepository.createMeasurement(
      heightCm: heightCm,
      weightKg: weightKg,
    );

    response.when(
      success: (measurement, _) {
        // Add the new measurement to the beginning of the list
        final updatedMeasurements = [measurement, ...currentMeasurements];
        emit(BmiState.saved(measurement, updatedMeasurements));
      },
      error: (message, _) => emit(BmiState.failure(message)),
    );
  }

  void clearSavedState() {
    final measurements = state.maybeWhen(
      saved: (_, measurements) => measurements,
      orElse: () => <BmiMeasurement>[],
    );
    if (measurements.isNotEmpty) {
      emit(BmiState.loaded(measurements));
    } else {
      emit(const BmiState.initial());
    }
  }
}
