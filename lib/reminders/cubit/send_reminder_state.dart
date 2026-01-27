import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_reminder_state.freezed.dart';

@freezed
sealed class SendReminderState with _$SendReminderState {
  const factory SendReminderState.initial() = SendReminderInitial;
  const factory SendReminderState.sending() = SendReminderSending;
  const factory SendReminderState.success() = SendReminderSuccess;
  const factory SendReminderState.failure(String message) = SendReminderFailure;
}
