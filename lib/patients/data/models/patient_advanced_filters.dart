import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_advanced_filters.freezed.dart';

@freezed
class PatientAdvancedFilters with _$PatientAdvancedFilters {
  const factory PatientAdvancedFilters({
    String? gender,
    double? bmiMin,
    double? bmiMax,
    int? systolicMin,
    int? systolicMax,
    int? diastolicMin,
    int? diastolicMax,
    double? sugarMin,
    double? sugarMax,
  }) = _PatientAdvancedFilters;

  const PatientAdvancedFilters._();

  bool get hasActiveFilters =>
      gender != null ||
      bmiMin != null ||
      bmiMax != null ||
      systolicMin != null ||
      systolicMax != null ||
      diastolicMin != null ||
      diastolicMax != null ||
      sugarMin != null ||
      sugarMax != null;

  int get activeFilterCount {
    var count = 0;
    if (gender != null) count++;
    if (bmiMin != null || bmiMax != null) count++;
    if (systolicMin != null || systolicMax != null) count++;
    if (diastolicMin != null || diastolicMax != null) count++;
    if (sugarMin != null || sugarMax != null) count++;
    return count;
  }

  Map<String, dynamic> toQueryMap() => {
        if (gender != null) 'gender': gender,
        if (bmiMin != null) 'bmi_min': bmiMin,
        if (bmiMax != null) 'bmi_max': bmiMax,
        if (systolicMin != null) 'systolic_min': systolicMin,
        if (systolicMax != null) 'systolic_max': systolicMax,
        if (diastolicMin != null) 'diastolic_min': diastolicMin,
        if (diastolicMax != null) 'diastolic_max': diastolicMax,
        if (sugarMin != null) 'sugar_min': sugarMin,
        if (sugarMax != null) 'sugar_max': sugarMax,
      };
}
