import 'dart:async';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/utils/download_file.dart';
import 'package:frontend/core/utils/snackbar_utils.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/survey/cubit/aggregated_results_cubit.dart';
import 'package:frontend/survey/cubit/aggregated_results_state.dart';
import 'package:frontend/survey/data/models/aggregated_option.dart';
import 'package:frontend/survey/data/models/aggregated_question.dart';
import 'package:frontend/survey/data/models/aggregated_survey_results.dart';
import 'package:frontend/survey/data/survey_repository.dart';

@RoutePage()
class AggregatedResultsPage extends StatelessWidget {
  const AggregatedResultsPage({
    @PathParam('surveyId') required this.surveyId,
    super.key,
  });

  final int surveyId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = AggregatedResultsCubit(
          surveyRepository: context.read<SurveyRepository>(),
        );
        unawaited(cubit.loadAggregatedResults(surveyId: surveyId));
        return cubit;
      },
      child: _AggregatedResultsView(surveyId: surveyId),
    );
  }
}

class _AggregatedResultsView extends StatelessWidget {
  const _AggregatedResultsView({required this.surveyId});

  final int surveyId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocConsumer<AggregatedResultsCubit, AggregatedResultsState>(
      listener: (context, state) {
        if (state is AggregatedResultsExported) {
          _downloadCsv(context, state.csvData);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.aggregatedResults),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            actions: [
              if (state is AggregatedResultsLoaded ||
                  state is AggregatedResultsExporting)
                IconButton(
                  onPressed: state is AggregatedResultsExporting
                      ? null
                      : () => context
                          .read<AggregatedResultsCubit>()
                          .exportToCsv(surveyId: surveyId),
                  icon: state is AggregatedResultsExporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download),
                  tooltip: l10n.exportResults,
                ),
            ],
          ),
          body: state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (results) => _AggregatedResultsContent(results: results),
            empty: () => _EmptyView(
              onRefresh: () => context
                  .read<AggregatedResultsCubit>()
                  .loadAggregatedResults(surveyId: surveyId),
            ),
            exporting: (results) =>
                _AggregatedResultsContent(results: results),
            exported: (results, _) =>
                _AggregatedResultsContent(results: results),
            error: (message) => _ErrorView(
              message: message,
              onRetry: () => context
                  .read<AggregatedResultsCubit>()
                  .loadAggregatedResults(surveyId: surveyId),
            ),
          ),
        );
      },
    );
  }

  void _downloadCsv(BuildContext context, Uint8List csvData) {
    final l10n = context.l10n;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'survey_results_${surveyId}_$timestamp.csv';

    final downloaded = downloadFile(
      bytes: csvData,
      fileName: fileName,
      mimeType: 'text/csv;charset=utf-8',
    );

    if (downloaded) {
      context.showSuccessSnackbar(l10n.exportSuccess);
    } else {
      context.showErrorSnackbar(l10n.exportNotSupported);
    }
  }
}

class _AggregatedResultsContent extends StatelessWidget {
  const _AggregatedResultsContent({required this.results});

  final AggregatedSurveyResults results;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Survey title
          Text(
            results.surveyTitle,
            style: context.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (results.surveyDescription != null) ...[
            const SizedBox(height: 8),
            Text(
              results.surveyDescription!,
              style: context.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Stats card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      icon: Icons.people,
                      label: l10n.completionRate,
                      value:
                          '${results.totalCompleted}/${results.totalAssigned}',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(context).dividerColor,
                  ),
                  Expanded(
                    child: _StatItem(
                      icon: Icons.percent,
                      label: '%',
                      value: '${results.completionRate.toStringAsFixed(1)}%',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Questions
          ...results.questions.map(
            (question) => _AggregatedQuestionCard(question: question),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: context.colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: context.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _AggregatedQuestionCard extends StatelessWidget {
  const _AggregatedQuestionCard({required this.question});

  final AggregatedQuestion question;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    question.questionText,
                    style: context.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (question.isRequired)
                  Icon(
                    Icons.star,
                    size: 16,
                    color: context.colorScheme.error,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.responsesCount(question.totalResponses),
              style: context.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuestionContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContent(BuildContext context) {
    // Text question
    if (question.questionType == 'text') {
      return _TextResponsesList(responses: question.textResponses ?? []);
    }

    // Choice question (single or multi)
    if (question.options != null && question.options!.isNotEmpty) {
      return Column(
        children: question.options!
            .map((option) => _OptionBarChart(option: option))
            .toList(),
      );
    }

    // No responses
    return Text(
      context.l10n.responsesCount(0),
      style: context.bodyMedium?.copyWith(
        color: context.colorScheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class _OptionBarChart extends StatelessWidget {
  const _OptionBarChart({required this.option});

  final AggregatedOption option;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: option.patients.isNotEmpty
          ? () => _showPatientListDialog(context, option)
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    option.optionText,
                    style: context.bodyMedium,
                  ),
                ),
                Text(
                  '${option.count} (${option.percentage.toStringAsFixed(1)}%)',
                  style: context.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: option.percentage / 100,
                minHeight: 20,
                backgroundColor: context.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  context.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPatientListDialog(BuildContext context, AggregatedOption option) {
    final l10n = context.l10n;

    unawaited(showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.patientsWhoSelected),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                option.optionText,
                style: dialogContext.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.patientsCount(option.patients.length),
                style: dialogContext.bodySmall?.copyWith(
                  color: dialogContext.colorScheme.onSurfaceVariant,
                ),
              ),
              if (option.patients.isNotEmpty) ...[
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: option.patients.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final patient = option.patients[index];
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              dialogContext.colorScheme.primaryContainer,
                          child: Text(
                            patient.name.isNotEmpty
                                ? patient.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  dialogContext.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        title: Text(
                          patient.name,
                          style: dialogContext.bodyMedium,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    ));
  }
}

class _TextResponsesList extends StatelessWidget {
  const _TextResponsesList({required this.responses});

  final List<String> responses;

  @override
  Widget build(BuildContext context) {
    if (responses.isEmpty) {
      return Text(
        context.l10n.responsesCount(0),
        style: context.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: responses.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (ctx, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ctx.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              responses[index],
              style: ctx.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.surveyResponsesEmpty,
              textAlign: TextAlign.center,
              style: context.bodyLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retryButton),
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retryButton),
            ),
          ],
        ),
      ),
    );
  }
}
