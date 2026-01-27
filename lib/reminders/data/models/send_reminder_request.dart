import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_reminder_request.freezed.dart';
part 'send_reminder_request.g.dart';

@freezed
class SendReminderRequest with _$SendReminderRequest {
  const factory SendReminderRequest({
    @JsonKey(name: 'recipient_id') required int recipientId,
    required String title,
    required String message,
  }) = _SendReminderRequest;

  factory SendReminderRequest.fromJson(Map<String, dynamic> json) =>
      _$SendReminderRequestFromJson(json);
}
