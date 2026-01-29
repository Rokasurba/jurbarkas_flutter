import 'package:freezed_annotation/freezed_annotation.dart';

part 'aggregated_option.freezed.dart';
part 'aggregated_option.g.dart';

@freezed
class PatientInfo with _$PatientInfo {
  const factory PatientInfo({
    required int id,
    required String name,
  }) = _PatientInfo;

  factory PatientInfo.fromJson(Map<String, dynamic> json) =>
      _$PatientInfoFromJson(json);
}

@freezed
class AggregatedOption with _$AggregatedOption {
  const factory AggregatedOption({
    @JsonKey(name: 'option_id') required int optionId,
    @JsonKey(name: 'option_text') required String optionText,
    required int count,
    required double percentage,
    @JsonKey(name: 'patient_ids') required List<int> patientIds,
    @Default([]) List<PatientInfo> patients,
  }) = _AggregatedOption;

  factory AggregatedOption.fromJson(Map<String, dynamic> json) =>
      _$AggregatedOptionFromJson(json);
}
