import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_doctor_request.freezed.dart';
part 'create_doctor_request.g.dart';

@freezed
class CreateDoctorRequest with _$CreateDoctorRequest {
  const factory CreateDoctorRequest({
    required String name,
    required String surname,
    required String email,
    String? phone,
  }) = _CreateDoctorRequest;

  factory CreateDoctorRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateDoctorRequestFromJson(json);
}
