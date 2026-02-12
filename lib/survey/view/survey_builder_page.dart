import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/data/patients_repository.dart';
import 'package:frontend/survey/cubit/survey_assignment_state.dart';
import 'package:frontend/survey/cubit/survey_builder_cubit.dart';
import 'package:frontend/survey/cubit/survey_builder_state.dart';
import 'package:frontend/survey/data/models/question_form_data.dart';
import 'package:frontend/survey/data/survey_repository.dart';

/// Translates error codes to localized messages.
String _translateError(String errorCode, AppLocalizations l10n) {
  return switch (errorCode) {
    'questions_required' => l10n.addAtLeastOneQuestion,
    'question_text_required' => l10n.questionTextRequired,
    'options_required' => l10n.addAtLeastTwoOptions,
    'option_text_required' => l10n.optionTextRequired,
    _ => errorCode,
  };
}

@RoutePage()
class SurveyBuilderPage extends StatelessWidget {
  const SurveyBuilderPage({
    @PathParam('surveyId') this.surveyId,
    super.key,
  });

  final int? surveyId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = SurveyBuilderCubit(
          surveyRepository: context.read<SurveyRepository>(),
          patientsRepository: context.read<PatientsRepository>(),
        );
        if (surveyId != null) {
          unawaited(cubit.initForEdit(surveyId!));
        } else {
          cubit.initForCreate();
        }
        return cubit;
      },
      child: _SurveyBuilderView(isEditMode: surveyId != null),
    );
  }
}

class _SurveyBuilderView extends StatefulWidget {
  const _SurveyBuilderView({required this.isEditMode});

  final bool isEditMode;

  @override
  State<_SurveyBuilderView> createState() => _SurveyBuilderViewState();
}

class _SurveyBuilderViewState extends State<_SurveyBuilderView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _currentTabIndex = 0;
  bool _patientsTabVisited = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _currentTabIndex = _tabController.index;
    });
    // Lazy-load patients when Pacientai tab is first visited
    if (_tabController.index == 1 && !_patientsTabVisited) {
      _patientsTabVisited = true;
      unawaited(context.read<SurveyBuilderCubit>().loadPatients());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<SurveyBuilderCubit, SurveyBuilderState>(
      listener: (context, state) {
        if (state is SurveyBuilderSaved) {
          AppSnackbar.showSuccess(
            context,
            widget.isEditMode ? l10n.surveyUpdated : l10n.surveyCreated,
          );
          unawaited(context.router.maybePop(true));
        } else if (state is SurveyBuilderError) {
          AppSnackbar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final showTabs = state is SurveyBuilderEditing ||
            state is SurveyBuilderSaving;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            title: Text(
              widget.isEditMode ? l10n.editSurvey : l10n.createSurvey,
              style: context.appBarTitle,
            ),
            bottom: showTabs
                ? TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: [
                      Tab(text: l10n.questionsSection),
                      Tab(text: l10n.assignPatientsTab),
                    ],
                  )
                : null,
          ),
          body: _buildBody(context, state),
          floatingActionButton:
              state is SurveyBuilderEditing &&
                      !state.hasResponses &&
                      _currentTabIndex == 0
                  ? FloatingActionButton.extended(
                      heroTag: 'addQuestionFab',
                      onPressed: () => _showAddQuestionSheet(context),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addQuestion),
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                    )
                  : null,
          bottomNavigationBar:
              state is SurveyBuilderEditing && !state.hasResponses
                  ? const _SaveButton(isLoading: false)
                  : state is SurveyBuilderSaving
                      ? const _SaveButton(isLoading: true)
                      : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SurveyBuilderState state) {
    return state.when(
      initial: () => const SizedBox.shrink(),
      loading: () => const Center(child: CircularProgressIndicator()),
      editing: (
        title,
        description,
        questions,
        isEditMode,
        hasResponses,
        surveyId,
        titleError,
        questionsError,
        allPatients,
        filteredPatients,
        selectedPatientIds,
        patientSearchQuery,
        patientsLoading,
        patientsError,
      ) =>
          TabBarView(
        controller: _tabController,
        children: [
          _SurveyBuilderForm(
            title: title,
            description: description,
            questions: questions,
            hasResponses: hasResponses,
            titleError: titleError,
            questionsError: questionsError,
          ),
          _PatientAssignmentTab(
            filteredPatients: filteredPatients,
            selectedPatientIds: selectedPatientIds,
            searchQuery: patientSearchQuery,
            isLoading: patientsLoading,
            error: patientsError,
            totalPatientCount: allPatients.length,
          ),
        ],
      ),
      saving: (title, description, questions, isEditMode, surveyId,
              selectedPatientIds) =>
          const Center(child: CircularProgressIndicator()),
      saved: (_) => const SizedBox.shrink(),
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
            AppButton.secondary(
              label: context.l10n.cancelButton,
              icon: Icons.arrow_back,
              onPressed: () => context.router.maybePop(),
              expand: false,
              size: AppButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddQuestionSheet(BuildContext context) {
    unawaited(showModalBottomSheet<QuestionFormData>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _QuestionEditorSheet(),
    ).then((question) {
      if (question != null) {
        context.read<SurveyBuilderCubit>().addQuestion(question);
      }
    }));
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isLoading});

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
          label: l10n.saveSurvey,
          onPressed: isLoading
              ? null
              : () => context.read<SurveyBuilderCubit>().saveSurvey(),
          isLoading: isLoading,
        ),
      ),
    );
  }
}

// --- Patient Assignment Tab ---

class _PatientAssignmentTab extends StatelessWidget {
  const _PatientAssignmentTab({
    required this.filteredPatients,
    required this.selectedPatientIds,
    required this.searchQuery,
    required this.isLoading,
    required this.totalPatientCount,
    this.error,
  });

  final List<PatientSelectionItem> filteredPatients;
  final Set<int> selectedPatientIds;
  final String searchQuery;
  final bool isLoading;
  final String? error;
  final int totalPatientCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            AppButton.secondary(
              label: l10n.retryButton,
              icon: Icons.refresh,
              onPressed: () =>
                  context.read<SurveyBuilderCubit>().loadPatients(),
              expand: false,
              size: AppButtonSize.medium,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: l10n.searchPlaceholder,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (query) =>
                context.read<SurveyBuilderCubit>().searchPatients(query),
          ),
        ),
        // Select all / none row + count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                l10n.selectedCount(selectedPatientIds.length),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    context.read<SurveyBuilderCubit>().selectAllPatients(),
                child: Text(l10n.selectAll),
              ),
              TextButton(
                onPressed: () =>
                    context.read<SurveyBuilderCubit>().deselectAllPatients(),
                child: Text(l10n.selectNone),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Patient list
        Expanded(
          child: filteredPatients.isEmpty
              ? Center(
                  child: Text(
                    l10n.noPatientsFound,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredPatients.length,
                  itemBuilder: (context, index) {
                    final item = filteredPatients[index];
                    final isSelected =
                        selectedPatientIds.contains(item.patient.id);
                    return _PatientCheckboxTile(
                      item: item,
                      isSelected: isSelected,
                      onToggle: () => context
                          .read<SurveyBuilderCubit>()
                          .togglePatient(item.patient.id),
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
    required this.onToggle,
  });

  final PatientSelectionItem item;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patient = item.patient;

    return CheckboxListTile(
      value: isSelected,
      onChanged: (_) => onToggle(),
      title: Text(
        patient.fullName,
        style: theme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        patient.patientCode ?? patient.email,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
      secondary: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          patient.initials,
          style: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}

// --- Survey Builder Form (Questions tab) ---

class _SurveyBuilderForm extends StatefulWidget {
  const _SurveyBuilderForm({
    required this.title,
    required this.description,
    required this.questions,
    required this.hasResponses,
    this.titleError,
    this.questionsError,
  });

  final String title;
  final String? description;
  final List<QuestionFormData> questions;
  final bool hasResponses;
  final String? titleError;
  final String? questionsError;

  @override
  State<_SurveyBuilderForm> createState() => _SurveyBuilderFormState();
}

class _SurveyBuilderFormState extends State<_SurveyBuilderForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(text: widget.description);
  }

  @override
  void didUpdateWidget(_SurveyBuilderForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title &&
        _titleController.text != widget.title) {
      _titleController.text = widget.title;
    }
    if (oldWidget.description != widget.description &&
        _descriptionController.text != widget.description) {
      _descriptionController.text = widget.description ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (widget.hasResponses) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.cannotEditSurveyWithResponses,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              AppButton.outlined(
                label: l10n.cancelButton,
                icon: Icons.arrow_back,
                onPressed: () => context.router.maybePop(),
                size: AppButtonSize.medium,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Title field
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.surveyTitle,
                  errorText: widget.titleError != null
                      ? l10n.enterTitle
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  context.read<SurveyBuilderCubit>().setTitle(value);
                },
              ),
              const SizedBox(height: 16),

              // Description field
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.surveyDescription,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  context.read<SurveyBuilderCubit>().setDescription(value);
                },
              ),
              const SizedBox(height: 24),

              // Questions section header
              Row(
                children: [
                  Text(
                    l10n.questionsSection,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.questions.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.questions.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                ],
              ),

              if (widget.questionsError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _translateError(widget.questionsError!, l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Questions list
              if (widget.questions.isEmpty)
                _EmptyQuestionsPlaceholder()
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.questions.length,
                  onReorder: (oldIndex, newIndex) {
                    context
                        .read<SurveyBuilderCubit>()
                        .reorderQuestions(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final question = widget.questions[index];
                    return _QuestionCard(
                      key: ValueKey(question.hashCode),
                      question: question,
                      index: index,
                      onEdit: () => _editQuestion(context, index, question),
                      onDelete: () => _confirmDeleteQuestion(context, index),
                    );
                  },
                ),

              // Bottom padding for FAB
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  void _editQuestion(
    BuildContext context,
    int index,
    QuestionFormData question,
  ) {
    unawaited(showModalBottomSheet<QuestionFormData>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _QuestionEditorSheet(existingQuestion: question),
    ).then((updatedQuestion) {
      if (updatedQuestion != null) {
        context.read<SurveyBuilderCubit>().updateQuestion(
              index,
              updatedQuestion,
            );
      }
    }));
  }

  void _confirmDeleteQuestion(BuildContext context, int index) {
    final l10n = context.l10n;

    unawaited(showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          Row(
            children: [
              Expanded(
                child: AppButton.outlined(
                  label: l10n.cancelButton,
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(false),
                  expand: true,
                  size: AppButtonSize.medium,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton.danger(
                  label: l10n.deleteButton,
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(true),
                  expand: true,
                  size: AppButtonSize.medium,
                ),
              ),
            ],
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed ?? false) {
        context.read<SurveyBuilderCubit>().removeQuestion(index);
      }
    }));
  }
}

class _EmptyQuestionsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(50),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.help_outline,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.addAtLeastOneQuestion,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final QuestionFormData question;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    String typeLabel;
    IconData typeIcon;
    switch (question.questionType) {
      case 'single':
        typeLabel = l10n.questionTypeSingle;
        typeIcon = Icons.radio_button_checked;
      case 'multi':
        typeLabel = l10n.questionTypeMulti;
        typeIcon = Icons.check_box;
      case 'text':
        typeLabel = l10n.questionTypeText;
        typeIcon = Icons.text_fields;
      default:
        typeLabel = question.questionType;
        typeIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Drag handle
                  ReorderableDragStartListener(
                    index: index,
                    child: Icon(
                      Icons.drag_handle,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Question number
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          typeIcon,
                          size: 14,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          typeLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (question.isRequired) ...[
                    const SizedBox(width: 8),
                    Text(
                      '*',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    color: theme.colorScheme.error,
                    tooltip: l10n.deleteButton,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                question.questionText.isEmpty
                    ? '(${l10n.questionText})'
                    : question.questionText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: question.questionText.isEmpty
                      ? theme.colorScheme.outline
                      : null,
                ),
              ),
              if (question.options.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: question.options.take(3).map((option) {
                    return Chip(
                      label: Text(
                        option.optionText.isEmpty
                            ? '(${l10n.optionText})'
                            : option.optionText,
                        style: theme.textTheme.bodySmall,
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
                if (question.options.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${question.options.length - 3}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionEditorSheet extends StatefulWidget {
  const _QuestionEditorSheet({this.existingQuestion});

  final QuestionFormData? existingQuestion;

  @override
  State<_QuestionEditorSheet> createState() => _QuestionEditorSheetState();
}

class _QuestionEditorSheetState extends State<_QuestionEditorSheet> {
  late final TextEditingController _questionTextController;
  late String _questionType;
  late bool _isRequired;
  late List<TextEditingController> _optionControllers;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingQuestion;
    _questionTextController = TextEditingController(
      text: existing?.questionText ?? '',
    );
    _questionType = existing?.questionType ?? 'single';
    _isRequired = existing?.isRequired ?? true;
    _optionControllers = existing?.options
            .map((o) => TextEditingController(text: o.optionText))
            .toList() ??
        [TextEditingController(), TextEditingController()];
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isEditing = widget.existingQuestion != null;
    final showOptions = _questionType != 'text';

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      isEditing ? l10n.editEntry : l10n.addQuestion,
                      style: theme.textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Question text
                    TextField(
                      controller: _questionTextController,
                      decoration: InputDecoration(
                        labelText: l10n.questionText,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Question type selector
                    Text(
                      l10n.questionTypeLabel,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'single',
                          label: Text(l10n.questionTypeSingle),
                          icon: const Icon(Icons.radio_button_checked),
                        ),
                        ButtonSegment(
                          value: 'multi',
                          label: Text(l10n.questionTypeMulti),
                          icon: const Icon(Icons.check_box),
                        ),
                        ButtonSegment(
                          value: 'text',
                          label: Text(l10n.questionTypeText),
                          icon: const Icon(Icons.text_fields),
                        ),
                      ],
                      selected: {_questionType},
                      onSelectionChanged: (selected) {
                        setState(() {
                          _questionType = selected.first;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Required toggle
                    SwitchListTile(
                      title: Text(l10n.questionRequired),
                      value: _isRequired,
                      onChanged: (value) {
                        setState(() {
                          _isRequired = value;
                        });
                      },
                    ),

                    // Options section (for single/multi)
                    if (showOptions) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            l10n.optionsSection,
                            style: theme.textTheme.titleSmall,
                          ),
                          const Spacer(),
                          AppButton.text(
                            label: l10n.addOption,
                            icon: Icons.add,
                            onPressed: _addOption,
                            size: AppButtonSize.small,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _optionControllers.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final item = _optionControllers.removeAt(oldIndex);
                            _optionControllers.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          return _OptionField(
                            key: ValueKey(_optionControllers[index]),
                            controller: _optionControllers[index],
                            index: index,
                            canDelete: _optionControllers.length > 2,
                            onDelete: () => _removeOption(index),
                          );
                        },
                      ),
                      if (_optionControllers.length < 2)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            l10n.addAtLeastTwoOptions,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                    ],

                    const SizedBox(height: 80),
                  ],
                ),
              ),
              // Save button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
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
                    label: l10n.saveButton,
                    onPressed: _saveQuestion,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= 2) return;
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
    });
  }

  void _saveQuestion() {
    final questionText = _questionTextController.text.trim();
    if (questionText.isEmpty) {
      AppSnackbar.showWarning(context, context.l10n.questionText);
      return;
    }

    if (_questionType != 'text' && _optionControllers.length < 2) {
      AppSnackbar.showWarning(context, context.l10n.addAtLeastTwoOptions);
      return;
    }

    final options = _questionType != 'text'
        ? _optionControllers
            .asMap()
            .entries
            .map(
              (entry) => OptionFormData(
                id: widget.existingQuestion?.options.elementAtOrNull(entry.key)?.id,
                optionText: entry.value.text.trim(),
                orderIndex: entry.key,
              ),
            )
            .toList()
        : <OptionFormData>[];

    final question = QuestionFormData(
      id: widget.existingQuestion?.id,
      questionText: questionText,
      questionType: _questionType,
      isRequired: _isRequired,
      orderIndex: widget.existingQuestion?.orderIndex ?? 0,
      options: options,
    );

    Navigator.of(context).pop(question);
  }
}

class _OptionField extends StatelessWidget {
  const _OptionField({
    required this.controller,
    required this.index,
    required this.canDelete,
    required this.onDelete,
    super.key,
  });

  final TextEditingController controller;
  final int index;
  final bool canDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_handle,
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: '${l10n.optionText} ${index + 1}',
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onDelete,
              color: theme.colorScheme.error,
            ),
        ],
      ),
    );
  }
}
