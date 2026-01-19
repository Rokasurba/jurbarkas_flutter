import 'package:freezed_annotation/freezed_annotation.dart';

part 'blood_pressure_reading.freezed.dart';
part 'blood_pressure_reading.g.dart';

@freezed
class BloodPressureReading with _$BloodPressureReading {
  const factory BloodPressureReading({
    required int id,
    required int systolic,
    required int diastolic,
    @JsonKey(name: 'measured_at') required DateTime measuredAt,
  }) = _BloodPressureReading;

  factory BloodPressureReading.fromJson(Map<String, dynamic> json) =>
      _$BloodPressureReadingFromJson(json);
}
