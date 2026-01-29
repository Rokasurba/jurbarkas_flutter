import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/survey/data/models/doctor_answer.dart';

part 'doctor_survey_results.freezed.dart';
part 'doctor_survey_results.g.dart';

@freezed
class DoctorSurveyResults with _$DoctorSurveyResults {
  const factory DoctorSurveyResults({
    @JsonKey(name: 'survey_id') required int surveyId,
    @JsonKey(name: 'survey_title') required String surveyTitle,
    @JsonKey(name: 'patient_id') required int patientId,
    @JsonKey(name: 'patient_name') required String patientName,
    @JsonKey(name: 'completed_at') required String completedAt,
    required List<DoctorAnswer> answers,
    @JsonKey(name: 'survey_description') String? surveyDescription,
  }) = _DoctorSurveyResults;

  factory DoctorSurveyResults.fromJson(Map<String, dynamic> json) =>
      _$DoctorSurveyResultsFromJson(json);
}
