import 'package:freezed_annotation/freezed_annotation.dart';

part 'blood_sugar_reading.freezed.dart';
part 'blood_sugar_reading.g.dart';

@freezed
class BloodSugarReading with _$BloodSugarReading {
  const factory BloodSugarReading({
    required int id,
    @JsonKey(name: 'glucose_level') required String glucoseLevel,
    @JsonKey(name: 'measured_at') required DateTime measuredAt,
  }) = _BloodSugarReading;

  factory BloodSugarReading.fromJson(Map<String, dynamic> json) =>
      _$BloodSugarReadingFromJson(json);
}
