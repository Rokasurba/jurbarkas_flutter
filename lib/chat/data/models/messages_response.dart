import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/chat/data/models/chat_message.dart';

part 'messages_response.freezed.dart';
part 'messages_response.g.dart';

@freezed
class MessagesResponse with _$MessagesResponse {
  const factory MessagesResponse({
    required List<ChatMessage> messages,
    @JsonKey(name: 'my_last_read_id') required int myLastReadId,
    @JsonKey(name: 'has_more') @Default(false) bool hasMore,
  }) = _MessagesResponse;

  factory MessagesResponse.fromJson(Map<String, dynamic> json) =>
      _$MessagesResponseFromJson(json);
}
