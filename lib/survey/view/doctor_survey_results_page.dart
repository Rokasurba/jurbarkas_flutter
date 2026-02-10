import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/survey/cubit/doctor_survey_results_cubit.dart';
import 'package:frontend/survey/cubit/doctor_survey_results_state.dart';
import 'package:frontend/survey/data/models/doctor_answer.dart';
import 'package:frontend/survey/data/models/doctor_survey_results.dart';
import 'package:frontend/survey/data/survey_repository.dart';

@RoutePage()
class DoctorSurveyResultsPage extends StatelessWidget {
  const DoctorSurveyResultsPage({
    @PathParam('surveyId') required this.surveyId,
    @PathParam('patientId') required this.patientId,
    super.key,
  });

  final int surveyId;
  final int patientId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = DoctorSurveyResultsCubit(
          surveyRepository: context.read<SurveyRepository>(),
        );
        unawaited(cubit.loadResults(surveyId: surveyId, patientId: patientId));
        return cubit;
      },
      child: const _DoctorSurveyResultsView(),
    );
  }
}

class _DoctorSurveyResultsView extends StatelessWidget {
  const _DoctorSurveyResultsView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.surveyResults),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<DoctorSurveyResultsCubit, DoctorSurveyResultsState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (results) => _DoctorResultsContent(results: results),
            empty: () => _EmptyView(
              onRetry: () {
                final cubit = context.read<DoctorSurveyResultsCubit>();
                final page = context.findAncestorWidgetOfExactType<
                    DoctorSurveyResultsPage>()!;
                unawaited(cubit.loadResults(
                  surveyId: page.surveyId,
                  patientId: page.patientId,
                ));
              },
            ),
            error: (message) => _ErrorView(
              message: message,
              onRetry: () {
                final cubit = context.read<DoctorSurveyResultsCubit>();
                final page = context.findAncestorWidgetOfExactType<
                    DoctorSurveyResultsPage>()!;
                unawaited(cubit.loadResults(
                  surveyId: page.surveyId,
                  patientId: page.patientId,
                ));
              },
            ),
          );
        },
      ),
    );
  }
}

class _DoctorResultsContent extends StatelessWidget {
  const _DoctorResultsContent({required this.results});

  final DoctorSurveyResults results;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Survey title
          Text(
            results.surveyTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (results.surveyDescription != null) ...[
            const SizedBox(height: 8),
            Text(
              results.surveyDescription!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Patient info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          results.patientName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.surveyCompletedOn}: '
                          '${_formatDate(results.completedAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Answers
          ...results.answers.map(
            (answer) => _AnswerCard(answer: answer),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.year}-$month-$day $hour:$minute';
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.answer});

  final DoctorAnswer answer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    answer.questionText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (answer.isRequired)
                  Icon(
                    Icons.star,
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAnswerDisplay(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerDisplay(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    // Single choice
    if (answer.selectedOptionText != null) {
      return Row(
        children: [
          Icon(
            Icons.check_circle,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              answer.selectedOptionText!,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      );
    }

    // Multi choice
    if (answer.selectedOptionTexts != null &&
        answer.selectedOptionTexts!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: answer.selectedOptionTexts!
            .map(
              (text) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(text)),
                  ],
                ),
              ),
            )
            .toList(),
      );
    }

    // Text answer
    if (answer.textAnswer != null && answer.textAnswer!.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          answer.textAnswer!,
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    // No answer
    return Text(
      l10n.surveyNoAnswer,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.surveyResponsesEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            AppButton.primary(
              label: l10n.retryButton,
              icon: Icons.refresh,
              onPressed: onRetry,
              expand: false,
              size: AppButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            AppButton.primary(
              label: l10n.retryButton,
              icon: Icons.refresh,
              onPressed: onRetry,
              expand: false,
              size: AppButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }
}
