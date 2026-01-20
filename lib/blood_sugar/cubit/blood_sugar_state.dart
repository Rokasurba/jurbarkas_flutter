part of 'blood_sugar_cubit.dart';

@freezed
sealed class BloodSugarState with _$BloodSugarState {
  const BloodSugarState._();

  const factory BloodSugarState.initial() = BloodSugarInitial;
  const factory BloodSugarState.loading() = BloodSugarLoading;
  const factory BloodSugarState.loaded(
    List<BloodSugarReading> readings, {
    @Default(true) bool hasMore,
  }) = BloodSugarLoaded;
  const factory BloodSugarState.loadingMore(
    List<BloodSugarReading> readings,
  ) = BloodSugarLoadingMore;
  const factory BloodSugarState.saving(
    List<BloodSugarReading> readings,
  ) = BloodSugarSaving;
  const factory BloodSugarState.saved(
    BloodSugarReading reading,
    List<BloodSugarReading> readings,
  ) = BloodSugarSaved;
  const factory BloodSugarState.updating(
    List<BloodSugarReading> readings,
  ) = BloodSugarUpdating;
  const factory BloodSugarState.updated(
    BloodSugarReading reading,
    List<BloodSugarReading> readings,
  ) = BloodSugarUpdated;
  const factory BloodSugarState.deleting(
    List<BloodSugarReading> readings,
  ) = BloodSugarDeleting;
  const factory BloodSugarState.deleted(
    List<BloodSugarReading> readings,
  ) = BloodSugarDeleted;
  const factory BloodSugarState.failure(String message) = BloodSugarFailure;

  bool get isLoading => this is BloodSugarLoading;
  bool get isSaving => this is BloodSugarSaving;
  bool get isUpdating => this is BloodSugarUpdating;
  bool get isDeleting => this is BloodSugarDeleting;
  bool get isLoadingMore => this is BloodSugarLoadingMore;

  bool get hasMore => maybeWhen(
        loaded: (_, hasMore) => hasMore,
        orElse: () => false,
      );

  List<BloodSugarReading> get readings => maybeWhen(
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
