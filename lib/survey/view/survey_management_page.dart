import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/core.dart';
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
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        title: Text(
          l10n.surveyListTitle,
          style: context.appBarTitle,
        ),
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
                  AppButton.primary(
                    label: l10n.retryButton,
                    icon: Icons.refresh,
                    onPressed: () =>
                        context.read<DoctorSurveyListCubit>().loadSurveys(),
                    expand: false,
                    size: AppButtonSize.medium,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'newSurveyFab',
        onPressed: () async {
          final created = await context.router.push<bool>(
            SurveyBuilderRoute(),
          );
          if ((created ?? false) && context.mounted) {
            await context.read<DoctorSurveyListCubit>().loadSurveys();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.newSurvey),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
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

  Future<void> _showActionMenu(BuildContext context) async {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final action = await showModalBottomSheet<_SurveyAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                survey.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: Text(l10n.surveyResults),
              onTap: () => Navigator.pop(context, _SurveyAction.results),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.editSurvey),
              onTap: () => Navigator.pop(context, _SurveyAction.edit),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: Text(l10n.assignSurvey),
              onTap: () => Navigator.pop(context, _SurveyAction.assign),
            ),
            ListTile(
              leading: Icon(Icons.delete, color: theme.colorScheme.error),
              title: Text(
                l10n.deleteSurvey,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () => Navigator.pop(context, _SurveyAction.delete),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (action == null || !context.mounted) return;

    switch (action) {
      case _SurveyAction.results:
        await context.router.push(
          SurveyResultsOverviewRoute(surveyId: survey.id),
        );
      case _SurveyAction.edit:
        final updated = await context.router.push<bool>(
          SurveyBuilderRoute(surveyId: survey.id),
        );
        if ((updated ?? false) && context.mounted) {
          await context.read<DoctorSurveyListCubit>().loadSurveys();
        }
      case _SurveyAction.assign:
        final assigned = await context.router.push<bool>(
          SurveyAssignmentRoute(surveyId: survey.id),
        );
        if ((assigned ?? false) && context.mounted) {
          await context.read<DoctorSurveyListCubit>().loadSurveys();
        }
      case _SurveyAction.delete:
        await _confirmDelete(context);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteSurveyTitle),
        content: Text(l10n.deleteSurveyConfirmation(survey.title)),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          Row(
            children: [
              Expanded(
                child: AppButton.outlined(
                  label: l10n.cancelButton,
                  onPressed: () => Navigator.pop(context, false),
                  expand: true,
                  size: AppButtonSize.medium,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton.danger(
                  label: l10n.deleteButton,
                  onPressed: () => Navigator.pop(context, true),
                  expand: true,
                  size: AppButtonSize.medium,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && context.mounted) {
      final repository = context.read<SurveyRepository>();
      final response = await repository.deleteSurvey(survey.id);

      if (!context.mounted) return;

      response.when(
        success: (data, message) {
          AppSnackbar.showSuccess(context, l10n.surveyDeleted);
          unawaited(context.read<DoctorSurveyListCubit>().loadSurveys());
        },
        error: (message, _) {
          AppSnackbar.showError(context, message);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showActionMenu(context),
        borderRadius: BorderRadius.circular(12),
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
                  AppButton.text(
                    label: l10n.surveyResults,
                    icon: Icons.bar_chart,
                    onPressed: () => context.router.push(
                      SurveyResultsOverviewRoute(surveyId: survey.id),
                    ),
                    size: AppButtonSize.small,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _SurveyAction { results, edit, assign, delete }

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
