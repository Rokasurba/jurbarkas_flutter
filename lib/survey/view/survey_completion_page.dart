import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/utils/snackbar_utils.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/survey/cubit/survey_completion_cubit.dart';
import 'package:frontend/survey/cubit/survey_completion_state.dart';
import 'package:frontend/survey/data/models/survey_answer.dart';
import 'package:frontend/survey/data/models/survey_for_completion.dart';
import 'package:frontend/survey/data/models/survey_question.dart';
import 'package:frontend/survey/data/survey_repository.dart';
import 'package:frontend/survey/view/survey_result_page.dart';

@RoutePage()
class SurveyCompletionPage extends StatelessWidget {
  const SurveyCompletionPage({
    @PathParam('assignmentId') required this.assignmentId, super.key,
    this.isCompleted = false,
  });

  final int assignmentId;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = SurveyCompletionCubit(
          surveyRepository: context.read<SurveyRepository>(),
        );
        unawaited(cubit.loadSurvey(assignmentId, isCompleted: isCompleted));
        return cubit;
      },
      child: const _SurveyCompletionView(),
    );
  }
}

class _SurveyCompletionView extends StatelessWidget {
  const _SurveyCompletionView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SurveyCompletionCubit, SurveyCompletionState>(
      listener: (context, state) {
        if (state is SurveyCompletionCompleted) {
          _showSuccessDialog(context, state.message);
        } else if (state is SurveyCompletionError) {
          AppSnackbar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        return state.when(
          initial: () => const Scaffold(
            body: SizedBox.shrink(),
          ),
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          loaded: (survey, currentIndex, answers) => _SurveyQuestionView(
            survey: survey,
            currentIndex: currentIndex,
            answers: answers,
            isSubmitting: false,
          ),
          submitting: (survey, currentIndex, answers) => _SurveyQuestionView(
            survey: survey,
            currentIndex: currentIndex,
            answers: answers,
            isSubmitting: true,
          ),
          completed: (message) => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          viewingCompleted: (completedSurvey) =>
              SurveyResultView(completedSurvey: completedSurvey),
          error: (message) => Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(message)),
          ),
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    final l10n = context.l10n;
    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.surveyCompletedSuccess),
        content: Text(message),
        actions: [
          AppButton.text(
            label: l10n.ok,
            onPressed: () {
              Navigator.of(dialogContext).pop();
              unawaited(context.router.maybePop(true));
            },
            size: AppButtonSize.small,
          ),
        ],
      ),
    ));
  }
}

class _SurveyQuestionView extends StatefulWidget {
  const _SurveyQuestionView({
    required this.survey,
    required this.currentIndex,
    required this.answers,
    required this.isSubmitting,
  });

  final SurveyForCompletion survey;
  final int currentIndex;
  final Map<int, SurveyAnswer> answers;
  final bool isSubmitting;

  @override
  State<_SurveyQuestionView> createState() => _SurveyQuestionViewState();
}

class _SurveyQuestionViewState extends State<_SurveyQuestionView> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _SurveyQuestionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _updateTextController();
    }
  }

  void _updateTextController() {
    final currentQuestion = widget.survey.questions[widget.currentIndex];
    final currentAnswer = widget.answers[currentQuestion.id];
    _textController.text = currentAnswer?.textAnswer ?? '';
  }

  @override
  void initState() {
    super.initState();
    _updateTextController();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final question = widget.survey.questions[widget.currentIndex];
    final totalQuestions = widget.survey.questions.length;
    final progress = (widget.currentIndex + 1) / totalQuestions;
    final isLastQuestion = widget.currentIndex == totalQuestions - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.currentIndex + 1}/$totalQuestions',
          style: context.appBarTitle,
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question text
                  Text(
                    question.questionText,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getInstructionText(question.questionType, l10n),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (question.isRequired) ...[
                    const SizedBox(height: 4),
                    Text(
                      '*${l10n.surveyRequiredQuestion}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Answer input based on question type
                  _buildAnswerInput(question),
                ],
              ),
            ),
          ),
          // Navigation buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (widget.currentIndex > 0)
                    Expanded(
                      child: AppButton.outlined(
                        label: l10n.previousQuestion,
                        onPressed: widget.isSubmitting
                            ? null
                            : () => context
                                .read<SurveyCompletionCubit>()
                                .previousQuestion(),
                        expand: true,
                      ),
                    ),
                  if (widget.currentIndex > 0) const SizedBox(width: 12),
                  Expanded(
                    child: AppButton.primary(
                      label: isLastQuestion
                          ? l10n.finishSurvey
                          : l10n.nextQuestion,
                      onPressed: widget.isSubmitting
                          ? null
                          : () => _handleNextOrSubmit(isLastQuestion),
                      isLoading: widget.isSubmitting,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInstructionText(String questionType, AppLocalizations l10n) {
    switch (questionType) {
      case 'single':
        return l10n.surveySelectOne;
      case 'multi':
        return l10n.surveySelectMultiple;
      case 'text':
        return l10n.surveyEnterText;
      default:
        return '';
    }
  }

  Widget _buildAnswerInput(SurveyQuestion question) {
    final currentAnswer = widget.answers[question.id];

    switch (question.questionType) {
      case 'single':
        return _buildSingleChoiceInput(question, currentAnswer);
      case 'multi':
        return _buildMultiChoiceInput(question, currentAnswer);
      case 'text':
        return _buildTextInput(question, currentAnswer);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSingleChoiceInput(
    SurveyQuestion question,
    SurveyAnswer? currentAnswer,
  ) {
    return Column(
      children: question.options.map((option) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: RadioListTile<int>(
            title: Text(option.optionText),
            value: option.id,
            groupValue: currentAnswer?.selectedOptionId,
            onChanged: (value) {
              if (value != null) {
                context.read<SurveyCompletionCubit>().answerQuestion(
                      question.id,
                      SurveyAnswer(
                        questionId: question.id,
                        selectedOptionId: value,
                      ),
                    );
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiChoiceInput(
    SurveyQuestion question,
    SurveyAnswer? currentAnswer,
  ) {
    final selectedIds = currentAnswer?.selectedOptionIds ?? [];

    return Column(
      children: question.options.map((option) {
        final isSelected = selectedIds.contains(option.id);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CheckboxListTile(
            title: Text(option.optionText),
            value: isSelected,
            onChanged: (value) {
              final newSelectedIds = List<int>.from(selectedIds);
              if (value ?? false) {
                newSelectedIds.add(option.id);
              } else {
                newSelectedIds.remove(option.id);
              }
              context.read<SurveyCompletionCubit>().answerQuestion(
                    question.id,
                    SurveyAnswer(
                      questionId: question.id,
                      selectedOptionIds: newSelectedIds,
                    ),
                  );
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextInput(
    SurveyQuestion question,
    SurveyAnswer? currentAnswer,
  ) {
    return TextFormField(
      controller: _textController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: context.l10n.surveyEnterTextHint,
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        final trimmed = value.trim();
        context.read<SurveyCompletionCubit>().answerQuestion(
              question.id,
              SurveyAnswer(
                questionId: question.id,
                textAnswer: trimmed.isEmpty ? null : trimmed,
              ),
            );
      },
    );
  }

  void _handleNextOrSubmit(bool isLastQuestion) {
    if (isLastQuestion) {
      unawaited(context.read<SurveyCompletionCubit>().submitSurvey());
    } else {
      context.read<SurveyCompletionCubit>().nextQuestion();
    }
  }
}
