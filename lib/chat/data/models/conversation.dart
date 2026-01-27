import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/chat/data/models/chat_message.dart';
import 'package:frontend/chat/data/models/user_brief.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required int id,
    @JsonKey(name: 'other_user') required UserBrief otherUser,
    @JsonKey(name: 'unread_count') required int unreadCount,
    @JsonKey(name: 'my_last_read_id') required int myLastReadId,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'last_message') ChatMessage? lastMessage,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}
