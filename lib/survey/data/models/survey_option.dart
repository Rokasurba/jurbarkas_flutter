import 'package:freezed_annotation/freezed_annotation.dart';

part 'survey_option.freezed.dart';
part 'survey_option.g.dart';

@freezed
class SurveyOption with _$SurveyOption {
  const factory SurveyOption({
    required int id,
    @JsonKey(name: 'option_text') required String optionText,
    @JsonKey(name: 'order_index') required int orderIndex,
  }) = _SurveyOption;

  factory SurveyOption.fromJson(Map<String, dynamic> json) =>
      _$SurveyOptionFromJson(json);
}
