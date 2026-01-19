part of 'blood_pressure_cubit.dart';

@freezed
sealed class BloodPressureState with _$BloodPressureState {
  const BloodPressureState._();

  const factory BloodPressureState.initial() = BloodPressureInitial;
  const factory BloodPressureState.loading() = BloodPressureLoading;
  const factory BloodPressureState.loaded(List<BloodPressureReading> readings) =
      BloodPressureLoaded;
  const factory BloodPressureState.saving() = BloodPressureSaving;
  const factory BloodPressureState.saved(
    BloodPressureReading reading,
    List<BloodPressureReading> readings,
  ) = BloodPressureSaved;
  const factory BloodPressureState.failure(String message) =
      BloodPressureFailure;

  bool get isLoading => this is BloodPressureLoading;
  bool get isSaving => this is BloodPressureSaving;

  List<BloodPressureReading> get readings => maybeWhen(
        loaded: (readings) => readings,
        saved: (_, readings) => readings,
        orElse: () => [],
      );
}
