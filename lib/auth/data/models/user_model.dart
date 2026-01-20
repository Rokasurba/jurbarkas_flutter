import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class User with _$User {

  const factory User({
    required int id,
    required String name,
    required String email,
    required String role,
    @Default('') String surname,
    String? phone,
    @JsonKey(name: 'date_of_birth') String? dateOfBirth,
    @JsonKey(name: 'patient_code') String? patientCode,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _User;
  const User._();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  String get fullName => '$name $surname'.trim();

  String get initials {
    final namePart = name.isNotEmpty ? name[0] : '';
    final surnamePart = surname.isNotEmpty ? surname[0] : '';
    return '$namePart$surnamePart'.toUpperCase();
  }

  bool get isPatient => role == 'patient';
  bool get isDoctor => role == 'doctor';
  bool get isAdmin => role == 'admin';
}
