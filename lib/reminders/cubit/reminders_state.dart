import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/reminders/data/models/reminder.dart';

part 'reminders_state.freezed.dart';

@freezed
sealed class RemindersState with _$RemindersState {
  const factory RemindersState.initial() = RemindersInitial;
  const factory RemindersState.loading() = RemindersLoading;
  const factory RemindersState.loaded(List<Reminder> reminders) =
      RemindersLoaded;
  const factory RemindersState.failure(String message) = RemindersFailure;
}
