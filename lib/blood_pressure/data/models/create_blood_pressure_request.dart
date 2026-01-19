import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_blood_pressure_request.freezed.dart';
part 'create_blood_pressure_request.g.dart';

@freezed
class CreateBloodPressureRequest with _$CreateBloodPressureRequest {
  const factory CreateBloodPressureRequest({
    required int systolic,
    required int diastolic,
    @JsonKey(name: 'measured_at') DateTime? measuredAt,
  }) = _CreateBloodPressureRequest;

  factory CreateBloodPressureRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBloodPressureRequestFromJson(json);
}
