import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/auth/data/models/user_model.dart';

part 'create_doctor_response.freezed.dart';
part 'create_doctor_response.g.dart';

@freezed
class CreateDoctorResponse with _$CreateDoctorResponse {
  const factory CreateDoctorResponse({
    required User user,
    @JsonKey(name: 'temporary_password') required String temporaryPassword,
  }) = _CreateDoctorResponse;

  factory CreateDoctorResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateDoctorResponseFromJson(json);
}
