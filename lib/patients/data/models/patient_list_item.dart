import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_list_item.freezed.dart';
part 'patient_list_item.g.dart';

@freezed
class PatientListItem with _$PatientListItem {

  const factory PatientListItem({
    required int id,
    required String name,
    required String surname,
    required String email,
    @JsonKey(name: 'patient_code') String? patientCode,
  }) = _PatientListItem;
  const PatientListItem._();

  factory PatientListItem.fromJson(Map<String, dynamic> json) =>
      _$PatientListItemFromJson(json);

  /// Full name combining name and surname
  String get fullName => '$name $surname';

  /// Initials from first letter of name and surname
  String get initials {
    final firstInitial = name.isNotEmpty ? name[0].toUpperCase() : '';
    final lastInitial = surname.isNotEmpty ? surname[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }
}

@freezed
class PatientsResponse with _$PatientsResponse {
  const factory PatientsResponse({
    required List<PatientListItem> patients,
    required int total,
    @JsonKey(name: 'has_more') required bool hasMore,
  }) = _PatientsResponse;

  factory PatientsResponse.fromJson(Map<String, dynamic> json) =>
      _$PatientsResponseFromJson(json);
}
