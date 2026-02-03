import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_patient_request.freezed.dart';
part 'update_patient_request.g.dart';

/// Request model for updating patient details.
@freezed
class UpdatePatientRequest with _$UpdatePatientRequest {
  const factory UpdatePatientRequest({
    String? name,
    String? surname,
    String? phone,
    @JsonKey(name: 'date_of_birth') String? dateOfBirth,
    @JsonKey(name: 'patient_code') String? patientCode,
  }) = _UpdatePatientRequest;

  factory UpdatePatientRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePatientRequestFromJson(json);
}
