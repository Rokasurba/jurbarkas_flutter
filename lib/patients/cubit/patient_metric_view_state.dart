part of 'patient_metric_view_cubit.dart';

@freezed
sealed class PatientMetricViewState with _$PatientMetricViewState {
  const PatientMetricViewState._();

  const factory PatientMetricViewState.initial() = _Initial;
  const factory PatientMetricViewState.loading() = _Loading;
  const factory PatientMetricViewState.bloodPressureLoaded(
    List<BloodPressureReading> readings,
  ) = _BloodPressureLoaded;
  const factory PatientMetricViewState.bloodSugarLoaded(
    List<BloodSugarReading> readings,
  ) = _BloodSugarLoaded;
  const factory PatientMetricViewState.bmiLoaded(
    List<BmiMeasurement> measurements,
  ) = _BmiLoaded;
  const factory PatientMetricViewState.failure(String message) = _Failure;

  bool get isLoading => this is _Loading;

  List<BloodPressureReading> get bloodPressureReadings => maybeWhen(
        bloodPressureLoaded: (readings) => readings,
        orElse: () => [],
      );

  List<BloodSugarReading> get bloodSugarReadings => maybeWhen(
        bloodSugarLoaded: (readings) => readings,
        orElse: () => [],
      );

  List<BmiMeasurement> get bmiMeasurements => maybeWhen(
        bmiLoaded: (measurements) => measurements,
        orElse: () => [],
      );
}
