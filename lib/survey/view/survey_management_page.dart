import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/survey/cubit/doctor_survey_list_cubit.dart';
import 'package:frontend/survey/cubit/doctor_survey_list_state.dart';
import 'package:frontend/survey/data/models/survey.dart';
import 'package:frontend/survey/data/survey_repository.dart';

@RoutePage()
class SurveyManagementPage extends StatelessWidget {
  const SurveyManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = DoctorSurveyListCubit(
          surveyRepository: context.read<SurveyRepository>(),
        );
        unawaited(cubit.loadSurveys());
        return cubit;
      },
      child: const _SurveyManagementView(),
    );
  }
}

class _SurveyManagementView extends StatelessWidget {
  const _SurveyManagementView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.surveyListTitle),
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<DoctorSurveyListCubit, DoctorSurveyListState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (surveys) => _SurveyListContent(surveys: surveys),
            error: (message) => Center(
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
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<DoctorSurveyListCubit>().loadSurveys(),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retryButton),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SurveyListContent extends StatelessWidget {
  const _SurveyListContent({required this.surveys});

  final List<Survey> surveys;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (surveys.isEmpty) {
      return Center(
        child: Text(l10n.surveysEmpty),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<DoctorSurveyListCubit>().loadSurveys(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: surveys.length,
        itemBuilder: (context, index) {
          final survey = surveys[index];
          return _SurveyCard(survey: survey);
        },
      ),
    );
  }
}

class _SurveyCard extends StatelessWidget {
  const _SurveyCard({required this.survey});

  final Survey survey;

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
                    survey.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!survey.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Neaktyvus',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
              ],
            ),
            if (survey.description != null) ...[
              const SizedBox(height: 8),
              Text(
                survey.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _StatChip(
                  icon: Icons.help_outline,
                  label: '${survey.questionCount}',
                ),
                const SizedBox(width: 12),
                _StatChip(
                  icon: Icons.people_outline,
                  label: '${survey.assignmentCount}',
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => context.router.push(
                    SurveyResultsOverviewRoute(surveyId: survey.id),
                  ),
                  icon: const Icon(Icons.bar_chart, size: 18),
                  label: Text(l10n.surveyResults),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
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
