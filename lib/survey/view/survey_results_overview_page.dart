import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/survey/cubit/aggregated_results_cubit.dart';
import 'package:frontend/survey/cubit/aggregated_results_state.dart';
import 'package:frontend/survey/data/models/aggregated_question.dart';
import 'package:frontend/survey/data/models/aggregated_survey_results.dart';
import 'package:frontend/survey/data/survey_repository.dart';

@RoutePage()
class SurveyResultsOverviewPage extends StatefulWidget {
  const SurveyResultsOverviewPage({
    @PathParam('surveyId') required this.surveyId,
    super.key,
  });

  final int surveyId;

  @override
  State<SurveyResultsOverviewPage> createState() =>
      _SurveyResultsOverviewPageState();
}

class _SurveyResultsOverviewPageState extends State<SurveyResultsOverviewPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = AggregatedResultsCubit(
          surveyRepository: context.read<SurveyRepository>(),
        );
        unawaited(cubit.loadAggregatedResults(surveyId: widget.surveyId));
        return cubit;
      },
      child: _SurveyResultsOverviewView(
        surveyId: widget.surveyId,
        selectedIndex: _selectedIndex,
        onIndexChanged: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

class _SurveyResultsOverviewView extends StatelessWidget {
  const _SurveyResultsOverviewView({
    required this.surveyId,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  final int surveyId;
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        title: Text(
          l10n.surveyResults,
          style: context.appBarTitle,
        ),
        actions: [
          if (selectedIndex == 1)
            BlocBuilder<AggregatedResultsCubit, AggregatedResultsState>(
              builder: (context, state) {
                final isLoaded = state is AggregatedResultsLoaded ||
                    state is AggregatedResultsExporting;
                final isExporting = state is AggregatedResultsExporting;

                if (!isLoaded) return const SizedBox.shrink();

                return IconButton(
                  onPressed: isExporting
                      ? null
                      : () => context
                          .read<AggregatedResultsCubit>()
                          .exportToCsv(surveyId: surveyId),
                  icon: isExporting
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
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(
                  value: 0,
                  label: Text(l10n.individualResults),
                  icon: const Icon(Icons.person),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text(l10n.aggregatedResults),
                  icon: const Icon(Icons.bar_chart),
                ),
              ],
              selected: {selectedIndex},
              onSelectionChanged: (selection) =>
                  onIndexChanged(selection.first),
            ),
          ),
          Expanded(
            child: selectedIndex == 0
                ? _IndividualResultsTab(surveyId: surveyId)
                : _AggregatedResultsTab(surveyId: surveyId),
          ),
        ],
      ),
    );
  }
}

class _IndividualResultsTab extends StatelessWidget {
  const _IndividualResultsTab({required this.surveyId});

  final int surveyId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocBuilder<AggregatedResultsCubit, AggregatedResultsState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (results) => _buildPatientList(context, results),
          empty: () => Center(
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
                ],
              ),
            ),
          ),
          exporting: (results) => _buildPatientList(context, results),
          exported: (results, _) => _buildPatientList(context, results),
          error: (message) => Center(
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
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  AppButton.primary(
                    label: l10n.retryButton,
                    icon: Icons.refresh,
                    onPressed: () => context
                        .read<AggregatedResultsCubit>()
                        .loadAggregatedResults(surveyId: surveyId),
                    expand: false,
                    size: AppButtonSize.medium,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatientList(
    BuildContext context,
    AggregatedSurveyResults results,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    // Collect all unique patient IDs from all options
    final patientIds = <int>{};
    for (final question in results.questions) {
      if (question.options != null) {
        for (final option in question.options!) {
          patientIds.addAll(option.patientIds);
        }
      }
    }

    if (patientIds.isEmpty) {
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
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: patientIds.length,
      itemBuilder: (context, index) {
        final patientId = patientIds.elementAt(index);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text('Pacientas #$patientId'),
            trailing: AppButton.text(
              label: l10n.viewSurveyResponse,
              onPressed: () => context.router.push(
                DoctorSurveyResultsRoute(
                  surveyId: surveyId,
                  patientId: patientId,
                ),
              ),
              size: AppButtonSize.small,
            ),
          ),
        );
      },
    );
  }
}

class _AggregatedResultsTab extends StatelessWidget {
  const _AggregatedResultsTab({required this.surveyId});

  final int surveyId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocBuilder<AggregatedResultsCubit, AggregatedResultsState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (results) => _AggregatedContent(results: results),
          empty: () => Center(
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
                ],
              ),
            ),
          ),
          exporting: (results) => _AggregatedContent(results: results),
          exported: (results, _) => _AggregatedContent(results: results),
          error: (message) => Center(
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
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  AppButton.primary(
                    label: l10n.retryButton,
                    icon: Icons.refresh,
                    onPressed: () => context
                        .read<AggregatedResultsCubit>()
                        .loadAggregatedResults(surveyId: surveyId),
                    expand: false,
                    size: AppButtonSize.medium,
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

class _AggregatedContent extends StatelessWidget {
  const _AggregatedContent({required this.results});

  final AggregatedSurveyResults results;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    color: theme.dividerColor,
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
          const SizedBox(height: 16),

          // Questions
          ...results.questions.map(
            (question) => _QuestionCard(question: question),
          ),
          const SizedBox(height: 16),
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
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question});

  final AggregatedQuestion question;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                    question.questionText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (question.isRequired)
                  Icon(
                    Icons.star,
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.responsesCount(question.totalResponses),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);

    // Text question
    if (question.questionType == 'text') {
      final responses = question.textResponses ?? [];
      if (responses.isEmpty) {
        return Text(
          context.l10n.responsesCount(0),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        );
      }

      return Container(
        constraints: const BoxConstraints(maxHeight: 150),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: responses.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(responses[index]),
            ),
          ),
        ),
      );
    }

    // Choice question
    final options = question.options ?? [];
    return Column(
      children: options.map((option) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(option.optionText)),
                  Text(
                    '${option.count} '
                    '(${option.percentage.toStringAsFixed(1)}%)',
                    style: theme.textTheme.bodyMedium?.copyWith(
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
                  minHeight: 16,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
