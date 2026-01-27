import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_brief.freezed.dart';
part 'user_brief.g.dart';

@freezed
class UserBrief with _$UserBrief {
  const factory UserBrief({
    required int id,
    required String name,
    required String surname,
    required String role,
  }) = _UserBrief;

  factory UserBrief.fromJson(Map<String, dynamic> json) =>
      _$UserBriefFromJson(json);
}
