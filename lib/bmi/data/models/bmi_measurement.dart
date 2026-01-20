import 'package:freezed_annotation/freezed_annotation.dart';

part 'bmi_measurement.freezed.dart';
part 'bmi_measurement.g.dart';

@freezed
class BmiMeasurement with _$BmiMeasurement {
  const factory BmiMeasurement({
    required int id,
    @JsonKey(name: 'height_cm') required int heightCm,
    @JsonKey(name: 'weight_kg') required double weightKg,
    @JsonKey(name: 'bmi_value') required double bmiValue,
    @JsonKey(name: 'measured_at') required DateTime measuredAt,
  }) = _BmiMeasurement;

  factory BmiMeasurement.fromJson(Map<String, dynamic> json) =>
      _$BmiMeasurementFromJson(json);
}
