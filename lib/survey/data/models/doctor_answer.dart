import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor_answer.freezed.dart';
part 'doctor_answer.g.dart';

@freezed
class DoctorAnswer with _$DoctorAnswer {
  const factory DoctorAnswer({
    @JsonKey(name: 'question_id') required int questionId,
    @JsonKey(name: 'question_text') required String questionText,
    @JsonKey(name: 'question_type') required String questionType,
    @JsonKey(name: 'is_required') required bool isRequired,
    @JsonKey(name: 'selected_option_text') String? selectedOptionText,
    @JsonKey(name: 'selected_option_texts') List<String>? selectedOptionTexts,
    @JsonKey(name: 'text_answer') String? textAnswer,
  }) = _DoctorAnswer;

  factory DoctorAnswer.fromJson(Map<String, dynamic> json) =>
      _$DoctorAnswerFromJson(json);
}
