import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/data/patients_repository.dart';
import 'package:frontend/survey/cubit/survey_assignment_cubit.dart';
import 'package:frontend/survey/cubit/survey_assignment_state.dart';
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
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            title: Text(
              l10n.assignSurvey,
              style: context.appBarTitle,
            ),
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
                  AppButton.primary(
                    label: l10n.retryButton,
                    icon: Icons.refresh,
                    onPressed: () {
                      unawaited(context.read<SurveyAssignmentCubit>().reload());
                    },
                    expand: false,
                    size: AppButtonSize.medium,
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
        child: AppButton.primary(
          label: '${l10n.assignSurvey} ($selectedCount)',
          onPressed: () =>
              context.read<SurveyAssignmentCubit>().assignToSelected(),
          isLoading: isLoading,
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
    final cubit = context.read<SurveyAssignmentCubit>();

    return Column(
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: l10n.searchPlaceholder,
              hintStyle: context.bodyMedium?.copyWith(
                color: AppColors.secondaryText.withValues(alpha: 0.6),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.secondary.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: AppColors.inputFill,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: cubit.searchPatients,
            style: context.bodyMedium,
          ),
        ),

        // Select all / none row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 20,
                color: selectedIds.isNotEmpty
                    ? AppColors.secondary
                    : theme.colorScheme.outline,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.selectedCount(selectedIds.length),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              AppButton.text(
                label: l10n.selectAll,
                onPressed: cubit.selectAll,
                size: AppButtonSize.small,
              ),
              const SizedBox(width: 8),
              AppButton.text(
                label: l10n.selectNone,
                onPressed: cubit.deselectAll,
                size: AppButtonSize.small,
              ),
            ],
          ),
        ),

        const Divider(height: 1),

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
                        cubit.togglePatient(item.patient.id);
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
