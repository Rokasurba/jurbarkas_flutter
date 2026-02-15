import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/survey/data/models/completed_survey.dart';

class SurveyResultView extends StatelessWidget {
  const SurveyResultView({required this.completedSurvey, super.key});

  final CompletedSurvey completedSurvey;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.surveyResults,
          style: context.appBarTitle,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Survey title
            Text(
              completedSurvey.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.surveyCompletedOn}: '
              '${_formatDate(completedSurvey.completedAt)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Answers
            ...completedSurvey.answers.map((qa) => _AnswerCard(
                  questionText: qa.questionText,
                  questionType: qa.questionType,
                  answer: qa.answer,
                )),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.questionText,
    required this.questionType,
    required this.answer,
  });

  final String questionText;
  final String questionType;
  final CompletedSurveyAnswer answer;

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
            Text(
              questionText,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
