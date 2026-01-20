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
  const factory BloodPressureState.updating(
    List<BloodPressureReading> readings,
  ) = BloodPressureUpdating;
  const factory BloodPressureState.updated(
    BloodPressureReading reading,
    List<BloodPressureReading> readings,
  ) = BloodPressureUpdated;
  const factory BloodPressureState.deleting(
    List<BloodPressureReading> readings,
  ) = BloodPressureDeleting;
  const factory BloodPressureState.deleted(
    List<BloodPressureReading> readings,
  ) = BloodPressureDeleted;
  const factory BloodPressureState.failure(String message) =
      BloodPressureFailure;

  bool get isLoading => this is BloodPressureLoading;
  bool get isSaving => this is BloodPressureSaving;
  bool get isUpdating => this is BloodPressureUpdating;
  bool get isDeleting => this is BloodPressureDeleting;
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
        updating: (readings) => readings,
        updated: (_, readings) => readings,
        deleting: (readings) => readings,
        deleted: (readings) => readings,
        orElse: () => [],
      );
}
