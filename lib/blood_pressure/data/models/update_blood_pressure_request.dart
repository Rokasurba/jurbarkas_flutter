import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_blood_pressure_request.freezed.dart';
part 'update_blood_pressure_request.g.dart';

@freezed
class UpdateBloodPressureRequest with _$UpdateBloodPressureRequest {
  const factory UpdateBloodPressureRequest({
    required int systolic,
    required int diastolic,
  }) = _UpdateBloodPressureRequest;

  factory UpdateBloodPressureRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateBloodPressureRequestFromJson(json);
}
