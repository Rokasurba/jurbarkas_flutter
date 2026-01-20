part of 'bmi_cubit.dart';

@freezed
sealed class BmiState with _$BmiState {
  const BmiState._();

  const factory BmiState.initial() = BmiInitial;
  const factory BmiState.loading() = BmiLoading;
  const factory BmiState.loaded(List<BmiMeasurement> measurements) = BmiLoaded;
  const factory BmiState.saving() = BmiSaving;
  const factory BmiState.saved(
    BmiMeasurement measurement,
    List<BmiMeasurement> measurements,
  ) = BmiSaved;
  const factory BmiState.failure(String message) = BmiFailure;

  bool get isLoading => this is BmiLoading;
  bool get isSaving => this is BmiSaving;

  List<BmiMeasurement> get measurements => maybeWhen(
        loaded: (measurements) => measurements,
        saved: (_, measurements) => measurements,
        orElse: () => [],
      );
}
