import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/survey/cubit/survey_completion_state.dart';
import 'package:frontend/survey/data/models/survey_answer.dart';
import 'package:frontend/survey/data/survey_repository.dart';

class SurveyCompletionCubit extends Cubit<SurveyCompletionState> {
  SurveyCompletionCubit({required SurveyRepository surveyRepository})
      : _surveyRepository = surveyRepository,
        super(const SurveyCompletionState.initial());

  final SurveyRepository _surveyRepository;

  Future<void> loadSurvey(int assignmentId, {bool isCompleted = false}) async {
    emit(const SurveyCompletionState.loading());

    if (isCompleted) {
      final response = await _surveyRepository.getCompletedSurvey(assignmentId);
      response.when(
        success: (completedSurvey, _) =>
            emit(SurveyCompletionState.viewingCompleted(completedSurvey)),
        error: (message, _) => emit(SurveyCompletionState.error(message)),
      );
    } else {
      final response =
          await _surveyRepository.getSurveyForCompletion(assignmentId);
      response.when(
        success: (survey, _) => emit(
          SurveyCompletionState.loaded(
            survey: survey,
            currentIndex: 0,
            answers: {},
          ),
        ),
        error: (message, _) => emit(SurveyCompletionState.error(message)),
      );
    }
  }

  void answerQuestion(int questionId, SurveyAnswer answer) {
    final currentState = state;
    if (currentState is SurveyCompletionLoaded) {
      final updatedAnswers = Map<int, SurveyAnswer>.from(currentState.answers)
        ..[questionId] = answer;

      emit(
        SurveyCompletionState.loaded(
          survey: currentState.survey,
          currentIndex: currentState.currentIndex,
          answers: updatedAnswers,
        ),
      );
    }
  }

  void nextQuestion() {
    final currentState = state;
    if (currentState is SurveyCompletionLoaded) {
      final maxIndex = currentState.survey.questions.length - 1;
      if (currentState.currentIndex < maxIndex) {
        emit(
          SurveyCompletionState.loaded(
            survey: currentState.survey,
            currentIndex: currentState.currentIndex + 1,
            answers: currentState.answers,
          ),
        );
      }
    }
  }

  void previousQuestion() {
    final currentState = state;
    if (currentState is SurveyCompletionLoaded) {
      if (currentState.currentIndex > 0) {
        emit(
          SurveyCompletionState.loaded(
            survey: currentState.survey,
            currentIndex: currentState.currentIndex - 1,
            answers: currentState.answers,
          ),
        );
      }
    }
  }

  Future<void> submitSurvey() async {
    final currentState = state;
    if (currentState is! SurveyCompletionLoaded) return;

    // Validate required questions have actual answers
    final requiredQuestions = currentState.survey.questions
        .where((q) => q.isRequired);

    final missingRequired = <int>[];
    for (final question in requiredQuestions) {
      final answer = currentState.answers[question.id];
      if (answer == null) {
        missingRequired.add(question.id);
        continue;
      }
      // Check if answer has actual content based on question type
      final hasContent = switch (question.questionType) {
        'single' => answer.selectedOptionId != null,
        'multi' => answer.selectedOptionIds?.isNotEmpty ?? false,
        'text' => answer.textAnswer?.trim().isNotEmpty ?? false,
        _ => true,
      };
      if (!hasContent) {
        missingRequired.add(question.id);
      }
    }

    if (missingRequired.isNotEmpty) {
      emit(const SurveyCompletionState.error(
        'Privaloma atsakyti į visus privalomus klausimus',
      ));
      // Restore state
      emit(
        SurveyCompletionState.loaded(
          survey: currentState.survey,
          currentIndex: currentState.currentIndex,
          answers: currentState.answers,
        ),
      );
      return;
    }

    emit(
      SurveyCompletionState.submitting(
        survey: currentState.survey,
        currentIndex: currentState.currentIndex,
        answers: currentState.answers,
      ),
    );

    final response = await _surveyRepository.submitSurveyAnswers(
      currentState.survey.assignmentId,
      currentState.answers.values.toList(),
    );

    response.when(
      success: (_, message) => emit(
        SurveyCompletionState.completed(message ?? 'Apklausa baigta!'),
      ),
      error: (message, _) {
        emit(SurveyCompletionState.error(message));
        // Restore state
        emit(
          SurveyCompletionState.loaded(
            survey: currentState.survey,
            currentIndex: currentState.currentIndex,
            answers: currentState.answers,
          ),
        );
      },
    );
  }
}
