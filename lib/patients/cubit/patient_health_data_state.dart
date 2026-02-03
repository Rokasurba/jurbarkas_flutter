part of 'patient_health_data_cubit.dart';

/// State for the patient health data page.
/// Uses Freezed sealed union types as required by project architecture.
@freezed
sealed class PatientHealthDataState with _$PatientHealthDataState {
  const PatientHealthDataState._();

  /// Initial state - not yet loaded.
  const factory PatientHealthDataState.initial() = PatientHealthDataInitial;

  /// Loading state - fetching health data from API.
  const factory PatientHealthDataState.loading() = PatientHealthDataLoading;

  /// Loaded state - all health data available.
  const factory PatientHealthDataState.loaded({
    required List<BloodPressureReading> bloodPressure,
    required List<BmiMeasurement> bmi,
    required List<BloodSugarReading> bloodSugar,
  }) = PatientHealthDataLoaded;

  /// Failure state - error occurred while loading.
  const factory PatientHealthDataState.failure(String message) =
      PatientHealthDataFailure;

  /// Returns true if currently loading.
  bool get isLoading => this is PatientHealthDataLoading;

  /// Returns blood pressure readings if loaded, empty list otherwise.
  List<BloodPressureReading> get bloodPressureOrEmpty => maybeWhen(
        loaded: (bp, bmi, bloodSugar) => bp,
        orElse: () => [],
      );

  /// Returns BMI measurements if loaded, empty list otherwise.
  List<BmiMeasurement> get bmiOrEmpty => maybeWhen(
        loaded: (bp, bmi, bloodSugar) => bmi,
        orElse: () => [],
      );

  /// Returns blood sugar readings if loaded, empty list otherwise.
  List<BloodSugarReading> get bloodSugarOrEmpty => maybeWhen(
        loaded: (bp, bmi, bs) => bs,
        orElse: () => [],
      );

  /// Returns the error message if in failure state, null otherwise.
  String? get errorOrNull => maybeWhen(
        failure: (message) => message,
        orElse: () => null,
      );
}
