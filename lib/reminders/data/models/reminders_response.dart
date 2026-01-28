import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/reminders/data/models/reminder.dart';

part 'reminders_response.freezed.dart';
part 'reminders_response.g.dart';

@freezed
class RemindersResponse with _$RemindersResponse {
  const factory RemindersResponse({
    required List<Reminder> reminders,
    @JsonKey(name: 'unread_count') required int unreadCount,
  }) = _RemindersResponse;

  factory RemindersResponse.fromJson(Map<String, dynamic> json) =>
      _$RemindersResponseFromJson(json);
}
