import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/reminders/cubit/reminders_cubit.dart';
import 'package:frontend/reminders/cubit/reminders_state.dart';
import 'package:frontend/reminders/data/models/reminder.dart';
import 'package:frontend/reminders/data/repositories/reminders_repository.dart';
import 'package:intl/intl.dart';

@RoutePage()
class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = RemindersCubit(
          remindersRepository: RemindersRepository(
            apiClient: context.read<ApiClient>(),
          ),
        );
        unawaited(cubit.loadReminders());
        return cubit;
      },
      child: const RemindersView(),
    );
  }
}

class RemindersView extends StatelessWidget {
  const RemindersView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ResponsiveBuilder(
      builder: (context, info) {
        final isMobile = info.isMobile;

        return ResponsiveScaffold(
          drawer: buildPatientDrawer(context, isMobile: isMobile),
          appBar: AppBar(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            leading: isMobile
                ? Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  )
                : const SizedBox.shrink(),
            title: Text(
              l10n.remindersTitle,
              style: context.appBarTitle,
            ),
            actions: [
              BlocBuilder<RemindersCubit, RemindersState>(
                builder: (context, state) {
                  final unreadCount = state.maybeWhen(
                    loaded: (reminders) =>
                        reminders.where((r) => r.readAt == null).length,
                    orElse: () => 0,
                  );
                  if (unreadCount == 0) return const SizedBox.shrink();
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Badge(
                        label: Text('$unreadCount'),
                        child: const Icon(Icons.notifications),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: BlocBuilder<RemindersCubit, RemindersState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            loaded: (reminders) {
              if (reminders.isEmpty) {
                return Center(
                  child: Text(
                    l10n.remindersEmpty,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () => context.read<RemindersCubit>().refresh(),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    return _ReminderCard(reminder: reminders[index]);
                  },
                ),
              );
            },
            failure: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    message,
                    style: TextStyle(color: context.errorColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<RemindersCubit>().loadReminders(),
                    child: Text(l10n.retryButton),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
      },
    );
  }
}

final _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context) {
    final isUnread = reminder.readAt == null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showReminderDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isUnread)
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 12),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              else
                const SizedBox(width: 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isUnread ? FontWeight.bold : FontWeight.normal,
                        color: AppColors.mainText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reminder.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${reminder.senderName} ${reminder.senderSurname}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _dateFormat.format(reminder.sentAt.toLocal()),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReminderDetail(BuildContext context) {
    final cubit = context.read<RemindersCubit>();
    if (reminder.readAt == null) {
      unawaited(cubit.markAsRead(reminder.id));
    }

    unawaited(showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          minChildSize: 0.3,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    reminder.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${reminder.senderName} ${reminder.senderSurname}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    _dateFormat.format(reminder.sentAt.toLocal()),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    reminder.message,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: AppColors.mainText,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ));
  }
}
