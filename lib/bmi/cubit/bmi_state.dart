part of 'bmi_cubit.dart';

@freezed
sealed class BmiState with _$BmiState {
  const BmiState._();

  const factory BmiState.initial() = BmiInitial;
  const factory BmiState.loading() = BmiLoading;
  const factory BmiState.loaded(
    List<BmiMeasurement> measurements, {
    @Default(true) bool hasMore,
  }) = BmiLoaded;
  const factory BmiState.loadingMore(
    List<BmiMeasurement> measurements,
  ) = BmiLoadingMore;
  const factory BmiState.saving(
    List<BmiMeasurement> measurements,
  ) = BmiSaving;
  const factory BmiState.saved(
    BmiMeasurement measurement,
    List<BmiMeasurement> measurements,
  ) = BmiSaved;
  const factory BmiState.updating(
    List<BmiMeasurement> measurements,
  ) = BmiUpdating;
  const factory BmiState.updated(
    BmiMeasurement measurement,
    List<BmiMeasurement> measurements,
  ) = BmiUpdated;
  const factory BmiState.deleting(
    List<BmiMeasurement> measurements,
  ) = BmiDeleting;
  const factory BmiState.deleted(
    List<BmiMeasurement> measurements,
  ) = BmiDeleted;
  const factory BmiState.failure(String message) = BmiFailure;

  bool get isLoading => this is BmiLoading;
  bool get isSaving => this is BmiSaving;
  bool get isUpdating => this is BmiUpdating;
  bool get isDeleting => this is BmiDeleting;
  bool get isLoadingMore => this is BmiLoadingMore;

  bool get hasMore => maybeWhen(
        loaded: (_, hasMore) => hasMore,
        orElse: () => false,
      );

  List<BmiMeasurement> get measurements => maybeWhen(
        loaded: (measurements, _) => measurements,
        loadingMore: (measurements) => measurements,
        saving: (measurements) => measurements,
        saved: (_, measurements) => measurements,
        updating: (measurements) => measurements,
        updated: (_, measurements) => measurements,
        deleting: (measurements) => measurements,
        deleted: (measurements) => measurements,
        orElse: () => [],
      );
}
