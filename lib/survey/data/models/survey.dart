import 'package:freezed_annotation/freezed_annotation.dart';

part 'survey.freezed.dart';
part 'survey.g.dart';

@freezed
class Survey with _$Survey {
  const factory Survey({
    required int id,
    required String title,
    @JsonKey(name: 'created_by') required int createdBy,
    @JsonKey(name: 'creator_name') required String creatorName,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'question_count') required int questionCount,
    @JsonKey(name: 'assignment_count') required int assignmentCount,
    @JsonKey(name: 'created_at') required String createdAt,
    String? description,
  }) = _Survey;

  factory Survey.fromJson(Map<String, dynamic> json) => _$SurveyFromJson(json);
}
