import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_doctor_request.freezed.dart';
part 'update_doctor_request.g.dart';

@freezed
class UpdateDoctorRequest with _$UpdateDoctorRequest {
  const factory UpdateDoctorRequest({
    String? name,
    String? surname,
    String? phone,
  }) = _UpdateDoctorRequest;

  factory UpdateDoctorRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateDoctorRequestFromJson(json);
}
