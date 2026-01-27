import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder.freezed.dart';
part 'reminder.g.dart';

@freezed
class Reminder with _$Reminder {
  const factory Reminder({
    required int id,
    @JsonKey(name: 'sender_id') required int senderId,
    @JsonKey(name: 'sender_name') required String senderName,
    @JsonKey(name: 'sender_surname') required String senderSurname,
    @JsonKey(name: 'recipient_id') required int recipientId,
    @JsonKey(name: 'recipient_name') required String recipientName,
    @JsonKey(name: 'recipient_surname') required String recipientSurname,
    required String title,
    required String message,
    @JsonKey(name: 'sent_at') required DateTime sentAt,
    @JsonKey(name: 'read_at') DateTime? readAt,
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);
}
