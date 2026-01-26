part of 'patient_bmi_view_cubit.dart';

@freezed
sealed class PatientBmiViewState with _$PatientBmiViewState {
  const PatientBmiViewState._();

  const factory PatientBmiViewState.initial() = _PatientBmiViewInitial;

  const factory PatientBmiViewState.loading() = _PatientBmiViewLoading;

  const factory PatientBmiViewState.loaded(
    List<BmiMeasurement> measurements,
  ) = _PatientBmiViewLoaded;

  const factory PatientBmiViewState.failure(String message) =
      _PatientBmiViewFailure;

  /// Get measurements if in loaded state, otherwise empty list.
  List<BmiMeasurement> get measurements => maybeWhen(
        loaded: (measurements) => measurements,
        orElse: () => [],
      );

  /// Whether data is currently loading.
  bool get isLoading => maybeWhen(
        loading: () => true,
        orElse: () => false,
      );
}
