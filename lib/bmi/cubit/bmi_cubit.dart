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
