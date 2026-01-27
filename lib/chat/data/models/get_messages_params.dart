import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_messages_params.freezed.dart';
part 'get_messages_params.g.dart';

@freezed
class GetMessagesParams with _$GetMessagesParams {
  const factory GetMessagesParams({
    int? limit,
    @JsonKey(name: 'after_id') int? afterId,
    @JsonKey(name: 'before_id') int? beforeId,
  }) = _GetMessagesParams;

  factory GetMessagesParams.fromJson(Map<String, dynamic> json) =>
      _$GetMessagesParamsFromJson(json);
}
