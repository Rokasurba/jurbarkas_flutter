import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/data/patients_repository.dart';
import 'package:frontend/survey/cubit/survey_assignment_cubit.dart';
import 'package:frontend/survey/cubit/survey_assignment_state.dart';
import 'package:frontend/core/utils/snackbar_utils.dart';
import 'package:frontend/survey/data/survey_repository.dart';

@RoutePage()
class SurveyAssignmentPage extends StatelessWidget {
  const SurveyAssignmentPage({
    @PathParam('surveyId') required this.surveyId,
    super.key,
  });

  final int surveyId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = SurveyAssignmentCubit(
          surveyRepository: context.read<SurveyRepository>(),
          patientsRepository: context.read<PatientsRepository>(),
        );
        unawaited(cubit.loadPatients(surveyId));
        return cubit;
      },
      child: const _SurveyAssignmentView(),
    );
  }
}

class _SurveyAssignmentView extends StatelessWidget {
  const _SurveyAssignmentView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<SurveyAssignmentCubit, SurveyAssignmentState>(
      listener: (context, state) {
        if (state is SurveyAssignmentAssigned) {
          AppSnackbar.showSuccess(
            context,
            l10n.surveyAssigned(state.assignedCount),
          );
          unawaited(context.router.maybePop(true));
        } else if (state is SurveyAssignmentError) {
          AppSnackbar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.assignSurvey),
            foregroundColor: Colors.white,
            actions: state is SurveyAssignmentLoaded
                ? [
                    if (state.selectedIds.isEmpty)
                      TextButton(
                        onPressed: () =>
                            context.read<SurveyAssignmentCubit>().selectAll(),
                        child: Text(
                          l10n.selectAll,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: () =>
                            context.read<SurveyAssignmentCubit>().deselectAll(),
                        child: Text(
                          l10n.selectNone,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                  ]
                : null,
          ),
          body: state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (
              allPatients,
              filteredPatients,
              selectedIds,
              surveyId,
              searchQuery,
            ) =>
                _PatientSelectionContent(
              patients: filteredPatients,
              selectedIds: selectedIds,
              searchQuery: searchQuery,
            ),
            assigning: (selectedIds, surveyId) => const Center(
              child: CircularProgressIndicator(),
            ),
            assigned: (assignedCount, skippedCount) => const SizedBox.shrink(),
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      unawaited(context.read<SurveyAssignmentCubit>().reload());
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retryButton),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: state is SurveyAssignmentLoaded &&
                  state.selectedIds.isNotEmpty
              ? _AssignButton(selectedCount: state.selectedIds.length)
              : state is SurveyAssignmentAssigning
                  ? const _AssignButton(selectedCount: 0, isLoading: true)
                  : null,
        );
      },
    );
  }
}

class _AssignButton extends StatelessWidget {
  const _AssignButton({
    required this.selectedCount,
    this.isLoading = false,
  });

  final int selectedCount;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: isLoading
                ? null
                : () => context.read<SurveyAssignmentCubit>().assignToSelected(),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('${l10n.assignSurvey} ($selectedCount)'),
          ),
        ),
      ),
    );
  }
}

class _PatientSelectionContent extends StatelessWidget {
  const _PatientSelectionContent({
    required this.patients,
    required this.selectedIds,
    required this.searchQuery,
  });

  final List<PatientSelectionItem> patients;
  final Set<int> selectedIds;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: l10n.searchPlaceholder,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) {
              context.read<SurveyAssignmentCubit>().searchPatients(value);
            },
          ),
        ),

        // Selected count indicator
        if (selectedIds.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: theme.colorScheme.primaryContainer,
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 20,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.selectedCount(selectedIds.length),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),

        // Patients list
        Expanded(
          child: patients.isEmpty
              ? Center(
                  child: Text(
                    searchQuery.isNotEmpty
                        ? l10n.noPatientsFound
                        : l10n.noPatients,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final item = patients[index];
                    final isSelected = selectedIds.contains(item.patient.id);

                    return _PatientCheckboxTile(
                      item: item,
                      isSelected: isSelected,
                      onChanged: (selected) {
                        context
                            .read<SurveyAssignmentCubit>()
                            .togglePatient(item.patient.id);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _PatientCheckboxTile extends StatelessWidget {
  const _PatientCheckboxTile({
    required this.item,
    required this.isSelected,
    required this.onChanged,
  });

  final PatientSelectionItem item;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patient = item.patient;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          patient.initials,
          style: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(patient.fullName),
      subtitle: patient.patientCode != null
          ? Text(patient.patientCode!)
          : Text(
              patient.email,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
      trailing: item.hasExistingAssignment
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                context.l10n.alreadyAssigned,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            )
          : Checkbox(
              value: isSelected,
              onChanged: (value) => onChanged(value ?? false),
            ),
      onTap: item.hasExistingAssignment
          ? null
          : () => onChanged(!isSelected),
    );
  }
}
