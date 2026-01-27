import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/reminders/cubit/reminders_state.dart';
import 'package:frontend/reminders/data/repositories/reminders_repository.dart';

class RemindersCubit extends Cubit<RemindersState> {
  RemindersCubit({
    required RemindersRepository remindersRepository,
  })  : _remindersRepository = remindersRepository,
        super(const RemindersState.initial());

  final RemindersRepository _remindersRepository;

  Future<void> loadReminders() async {
    emit(const RemindersState.loading());

    final response = await _remindersRepository.getReminders();

    response.when(
      success: (reminders, _) {
        final sorted = List.of(reminders)
          ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
        emit(RemindersState.loaded(sorted));
      },
      error: (message, _) => emit(RemindersState.failure(message)),
    );
  }

  Future<void> refresh() async => loadReminders();

  Future<void> markAsRead(int reminderId) async {
    final response = await _remindersRepository.markAsRead(reminderId);

    response.when(
      success: (_, _) {
        final currentState = state;
        if (currentState is RemindersLoaded) {
          final updatedReminders = currentState.reminders.map((reminder) {
            if (reminder.id == reminderId && reminder.readAt == null) {
              return reminder.copyWith(readAt: DateTime.now());
            }
            return reminder;
          }).toList();
          emit(RemindersState.loaded(updatedReminders));
        }
      },
      error: (_, _) {
        // Silently fail — reminder is still viewable
      },
    );
  }
}
