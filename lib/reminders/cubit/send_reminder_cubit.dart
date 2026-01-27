import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/reminders/cubit/send_reminder_state.dart';
import 'package:frontend/reminders/data/models/send_reminder_request.dart';
import 'package:frontend/reminders/data/repositories/reminders_repository.dart';

class SendReminderCubit extends Cubit<SendReminderState> {
  SendReminderCubit({
    required RemindersRepository remindersRepository,
    required this.recipientId,
  })  : _remindersRepository = remindersRepository,
        super(const SendReminderState.initial());

  final RemindersRepository _remindersRepository;
  final int recipientId;

  Future<void> sendReminder({
    required String title,
    required String message,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedMessage = message.trim();

    // Reset to initial first so repeated identical failures re-trigger listener
    emit(const SendReminderState.initial());

    if (trimmedTitle.isEmpty || trimmedMessage.isEmpty) {
      emit(const SendReminderState.failure('fillAllFields'));
      return;
    }

    if (trimmedTitle.length > 100) {
      emit(const SendReminderState.failure('titleMaxLength'));
      return;
    }

    emit(const SendReminderState.sending());

    final request = SendReminderRequest(
      recipientId: recipientId,
      title: trimmedTitle,
      message: trimmedMessage,
    );

    final response = await _remindersRepository.sendReminder(request);

    response.when(
      success: (_, _) => emit(const SendReminderState.success()),
      error: (message, _) => emit(SendReminderState.failure(message)),
    );
  }
}
