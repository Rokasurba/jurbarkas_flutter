import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/blood_pressure/data/models/blood_pressure_reading.dart';
import 'package:frontend/blood_sugar/data/models/blood_sugar_reading.dart';
import 'package:frontend/bmi/data/models/bmi_measurement.dart';

part 'patient_health_data_response.freezed.dart';
part 'patient_health_data_response.g.dart';

/// Response model for aggregated patient health data.
///
/// Contains all three types of health data: blood pressure, BMI, and blood sugar.
@freezed
class PatientHealthDataResponse with _$PatientHealthDataResponse {
  const factory PatientHealthDataResponse({
    @JsonKey(name: 'blood_pressure')
    required List<BloodPressureReading> bloodPressure,
    required List<BmiMeasurement> bmi,
    @JsonKey(name: 'blood_sugar') required List<BloodSugarReading> bloodSugar,
  }) = _PatientHealthDataResponse;

  factory PatientHealthDataResponse.fromJson(Map<String, dynamic> json) =>
      _$PatientHealthDataResponseFromJson(json);
}
