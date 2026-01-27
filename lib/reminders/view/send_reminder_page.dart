import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/reminders/cubit/send_reminder_cubit.dart';
import 'package:frontend/reminders/cubit/send_reminder_state.dart';
import 'package:frontend/reminders/data/repositories/reminders_repository.dart';

@RoutePage()
class SendReminderPage extends StatelessWidget {
  const SendReminderPage({
    required this.patientId,
    required this.patientName,
    super.key,
  });

  final int patientId;
  final String patientName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SendReminderCubit(
        remindersRepository: RemindersRepository(
          apiClient: context.read<ApiClient>(),
        ),
        recipientId: patientId,
      ),
      child: SendReminderView(patientName: patientName),
    );
  }
}

class SendReminderView extends StatefulWidget {
  const SendReminderView({required this.patientName, super.key});

  final String patientName;

  @override
  State<SendReminderView> createState() => _SendReminderViewState();
}

class _SendReminderViewState extends State<SendReminderView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    unawaited(
      context.read<SendReminderCubit>().sendReminder(
            title: _titleController.text,
            message: _messageController.text,
          ),
    );
  }

  String _resolveErrorMessage(BuildContext context, String error) {
    final l10n = context.l10n;
    return switch (error) {
      'fillAllFields' => l10n.fillAllFieldsError,
      'titleMaxLength' => l10n.titleMaxLengthError,
      _ => error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<SendReminderCubit, SendReminderState>(
      listener: (context, state) {
        state.whenOrNull(
          success: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.reminderSentSuccess),
                backgroundColor: Colors.green,
              ),
            );
            unawaited(context.router.maybePop());
          },
          failure: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_resolveErrorMessage(context, message)),
                backgroundColor: AppColors.error,
              ),
            );
          },
        );
      },
      builder: (context, state) {
        final isSending = state is SendReminderSending;

        return ResponsiveScaffold(
          appBar: AppBar(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            title: Text(
              l10n.sendReminderTitle,
              style: context.appBarTitle,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient name (read-only)
                  Text(
                    l10n.reminderPatientLabel,
                    style: context.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.patientName,
                    style: context.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainText,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title field
                  TextFormField(
                    controller: _titleController,
                    enabled: !isSending,
                    maxLength: 100,
                    decoration: InputDecoration(
                      labelText: l10n.reminderTitleLabel,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Message field
                  TextFormField(
                    controller: _messageController,
                    enabled: !isSending,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: l10n.reminderMessageLabel,
                      border: const OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isSending ? null : _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 0,
                      ),
                      child: isSending
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              l10n.sendButton,
                              style: context.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
