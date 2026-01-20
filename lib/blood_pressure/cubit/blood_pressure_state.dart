part of 'blood_pressure_cubit.dart';

@freezed
sealed class BloodPressureState with _$BloodPressureState {
  const BloodPressureState._();

  const factory BloodPressureState.initial() = BloodPressureInitial;
  const factory BloodPressureState.loading() = BloodPressureLoading;
  const factory BloodPressureState.loaded(
    List<BloodPressureReading> readings, {
    @Default(true) bool hasMore,
  }) = BloodPressureLoaded;
  const factory BloodPressureState.loadingMore(
    List<BloodPressureReading> readings,
  ) = BloodPressureLoadingMore;
  const factory BloodPressureState.saving(
    List<BloodPressureReading> readings,
  ) = BloodPressureSaving;
  const factory BloodPressureState.saved(
    BloodPressureReading reading,
    List<BloodPressureReading> readings,
  ) = BloodPressureSaved;
  const factory BloodPressureState.failure(String message) =
      BloodPressureFailure;

  bool get isLoading => this is BloodPressureLoading;
  bool get isSaving => this is BloodPressureSaving;
  bool get isLoadingMore => this is BloodPressureLoadingMore;

  bool get hasMore => maybeWhen(
        loaded: (_, hasMore) => hasMore,
        orElse: () => false,
      );

  List<BloodPressureReading> get readings => maybeWhen(
        loaded: (readings, _) => readings,
        loadingMore: (readings) => readings,
        saving: (readings) => readings,
        saved: (_, readings) => readings,
        orElse: () => [],
      );
}
