import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/survey/cubit/survey_list_cubit.dart';
import 'package:frontend/survey/cubit/survey_list_state.dart';
import 'package:frontend/survey/data/models/assigned_survey.dart';
import 'package:frontend/survey/data/survey_repository.dart';

@RoutePage()
class MySurveysPage extends StatelessWidget {
  const MySurveysPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = SurveyListCubit(
          surveyRepository: context.read<SurveyRepository>(),
        );
        unawaited(cubit.loadAssignedSurveys());
        return cubit;
      },
      child: const _MySurveysView(),
    );
  }
}

class _MySurveysView extends StatelessWidget {
  const _MySurveysView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.surveyListTitle,
          style: context.appBarTitle,
        ),
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<SurveyListCubit, SurveyListState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (surveys) => _SurveyListContent(surveys: surveys),
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(message),
                  const SizedBox(height: 16),
                  AppButton.primary(
                    label: l10n.retry,
                    onPressed: () =>
                        context.read<SurveyListCubit>().loadAssignedSurveys(),
                    expand: false,
                    size: AppButtonSize.medium,
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

  final List<AssignedSurvey> surveys;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (surveys.isEmpty) {
      return Center(
        child: Text(l10n.surveysEmpty),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<SurveyListCubit>().loadAssignedSurveys(),
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

  final AssignedSurvey survey;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          unawaited(context.router.push(
            SurveyCompletionRoute(
              assignmentId: survey.id,
              isCompleted: survey.isCompleted,
            ),
          ));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      survey.surveyTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(survey.assignedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: survey.isCompleted
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        survey.isCompleted
                            ? l10n.surveyCompleted
                            : l10n.surveyNotStarted,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: survey.isCompleted
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
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
