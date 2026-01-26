part of 'patient_blood_pressure_view_cubit.dart';

@freezed
sealed class PatientBloodPressureViewState
    with _$PatientBloodPressureViewState {
  const PatientBloodPressureViewState._();

  const factory PatientBloodPressureViewState.initial() =
      _PatientBloodPressureViewInitial;

  const factory PatientBloodPressureViewState.loading() =
      _PatientBloodPressureViewLoading;

  const factory PatientBloodPressureViewState.loaded(
    List<BloodPressureReading> readings,
  ) = _PatientBloodPressureViewLoaded;

  const factory PatientBloodPressureViewState.failure(String message) =
      _PatientBloodPressureViewFailure;

  /// Get readings if in loaded state, otherwise empty list.
  List<BloodPressureReading> get readings => maybeWhen(
        loaded: (readings) => readings,
        orElse: () => [],
      );

  /// Whether data is currently loading.
  bool get isLoading => maybeWhen(
        loading: () => true,
        orElse: () => false,
      );
}
