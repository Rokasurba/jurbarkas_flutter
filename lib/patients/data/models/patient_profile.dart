import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_profile.freezed.dart';
part 'patient_profile.g.dart';

/// Detailed patient profile model for the patient detail view.
/// Contains all fields needed for the profile page including optional fields.
@freezed
class PatientProfile with _$PatientProfile {

  const factory PatientProfile({
    required int id,
    required String name,
    required String surname,
    required String email,
    @JsonKey(name: 'is_active') required bool isActive, @JsonKey(name: 'created_at') required DateTime createdAt, String? phone,
    @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
    @JsonKey(name: 'patient_code') String? patientCode,
  }) = _PatientProfile;
  const PatientProfile._();

  factory PatientProfile.fromJson(Map<String, dynamic> json) =>
      _$PatientProfileFromJson(json);

  /// Full name combining name and surname
  String get fullName => '$name $surname';

  /// Initials from first letter of name and surname
  String get initials {
    final firstInitial = name.isNotEmpty ? name[0].toUpperCase() : '';
    final lastInitial = surname.isNotEmpty ? surname[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }
}
