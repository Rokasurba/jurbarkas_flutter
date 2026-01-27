import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_conversation_request.freezed.dart';
part 'create_conversation_request.g.dart';

@freezed
class CreateConversationRequest with _$CreateConversationRequest {
  const factory CreateConversationRequest({
    @JsonKey(name: 'user_id') required int userId,
  }) = _CreateConversationRequest;

  factory CreateConversationRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateConversationRequestFromJson(json);
}
