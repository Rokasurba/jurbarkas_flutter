import 'package:bloc/bloc.dart';
import 'package:frontend/survey/cubit/survey_builder_state.dart';
import 'package:frontend/survey/data/models/create_survey_request.dart';
import 'package:frontend/survey/data/models/question_form_data.dart';
import 'package:frontend/survey/data/survey_repository.dart';

class SurveyBuilderCubit extends Cubit<SurveyBuilderState> {
  SurveyBuilderCubit({
    required SurveyRepository surveyRepository,
  })  : _surveyRepository = surveyRepository,
        super(const SurveyBuilderState.initial());

  final SurveyRepository _surveyRepository;

  /// Initialize for creating a new survey.
  void initForCreate() {
    emit(
      const SurveyBuilderState.editing(
        title: '',
        description: null,
        questions: [],
        isEditMode: false,
        hasResponses: false,
        surveyId: null,
      ),
    );
  }

  /// Initialize for editing an existing survey.
  Future<void> initForEdit(int surveyId) async {
    emit(const SurveyBuilderState.loading());

    final response = await _surveyRepository.getSurveyDetails(surveyId);

    response.when(
      success: (details, _) {
        // Check if survey has responses (completed assignments)
        // For now we'll assume hasResponses = false since the API doesn't
        // include this directly. The UI will handle the "cannot edit" case
        // if the update API returns an error.
        final questions = details.questions
            .map(
              (q) => QuestionFormData(
                id: q.id,
                questionText: q.questionText,
                questionType: q.questionType,
                isRequired: q.isRequired,
                orderIndex: q.orderIndex,
                options: q.options
                    .map(
                      (o) => OptionFormData(
                        id: o.id,
                        optionText: o.optionText,
                        orderIndex: o.orderIndex,
                      ),
                    )
                    .toList(),
              ),
            )
            .toList();

        emit(
          SurveyBuilderState.editing(
            title: details.title,
            description: details.description,
            questions: questions,
            isEditMode: true,
            hasResponses: false, // Will be determined on save attempt
            surveyId: surveyId,
          ),
        );
      },
      error: (message, _) {
        emit(SurveyBuilderState.error(message));
      },
    );
  }

  /// Update the survey title.
  void setTitle(String title) {
    final currentState = state;
    if (currentState is SurveyBuilderEditing) {
      emit(
        currentState.copyWith(
          title: title,
          titleError: null,
        ),
      );
    }
  }

  /// Update the survey description.
  void setDescription(String? description) {
    final currentState = state;
    if (currentState is SurveyBuilderEditing) {
      emit(
        currentState.copyWith(
          description: description?.isEmpty ?? true ? null : description,
        ),
      );
    }
  }

  /// Add a new question.
  void addQuestion(QuestionFormData question) {
    final currentState = state;
    if (currentState is SurveyBuilderEditing) {
      final updatedQuestions = [
        ...currentState.questions,
        question.copyWith(orderIndex: currentState.questions.length),
      ];
      emit(
        currentState.copyWith(
          questions: updatedQuestions,
          questionsError: null,
        ),
      );
    }
  }

  /// Remove a question at the given index.
  void removeQuestion(int index) {
    final currentState = state;
    if (currentState is SurveyBuilderEditing) {
      final updatedQuestions = List<QuestionFormData>.from(
        currentState.questions,
      )..removeAt(index);
      // Update order indices
      for (var i = 0; i < updatedQuestions.length; i++) {
        updatedQuestions[i].orderIndex = i;
      }
      emit(currentState.copyWith(questions: updatedQuestions));
    }
  }

  /// Update a question at the given index.
  void updateQuestion(int index, QuestionFormData question) {
    final currentState = state;
    if (currentState is SurveyBuilderEditing) {
      final updatedQuestions = List<QuestionFormData>.from(
        currentState.questions,
      );
      updatedQuestions[index] = question.copyWith(orderIndex: index);
      emit(
        currentState.copyWith(
          questions: updatedQuestions,
          questionsError: null,
        ),
      );
    }
  }

  /// Reorder questions after drag-and-drop.
  void reorderQuestions(int oldIndex, int newIndex) {
    final currentState = state;
    if (currentState is SurveyBuilderEditing) {
      final updatedQuestions = List<QuestionFormData>.from(
        currentState.questions,
      );
      final adjustedNewIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
      final item = updatedQuestions.removeAt(oldIndex);
      updatedQuestions.insert(adjustedNewIndex, item);
      // Update order indices
      for (var i = 0; i < updatedQuestions.length; i++) {
        updatedQuestions[i].orderIndex = i;
      }
      emit(currentState.copyWith(questions: updatedQuestions));
    }
  }

  /// Validate the survey before saving.
  /// Returns null if valid, or an error message if invalid.
  String? _validate(SurveyBuilderEditing currentState) {
    if (currentState.title.trim().isEmpty) {
      return 'title_required';
    }
    if (currentState.questions.isEmpty) {
      return 'questions_required';
    }
    for (final question in currentState.questions) {
      final error = question.validate();
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  /// Save the survey (create or update).
  Future<void> saveSurvey() async {
    final currentState = state;
    if (currentState is! SurveyBuilderEditing) return;

    // Validate
    final error = _validate(currentState);
    if (error != null) {
      if (error == 'title_required') {
        emit(currentState.copyWith(titleError: error));
      } else if (error == 'questions_required') {
        emit(currentState.copyWith(questionsError: error));
      } else {
        emit(currentState.copyWith(questionsError: error));
      }
      return;
    }

    // Create request
    final request = CreateSurveyRequest(
      title: currentState.title.trim(),
      description: currentState.description?.trim(),
      questions: currentState.questions
          .map(
            (q) => CreateQuestionRequest(
              questionText: q.questionText.trim(),
              questionType: q.questionType,
              isRequired: q.isRequired,
              orderIndex: q.orderIndex,
              options: q.options
                  .map(
                    (o) => CreateOptionRequest(
                      optionText: o.optionText.trim(),
                      orderIndex: o.orderIndex,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );

    emit(
      SurveyBuilderState.saving(
        title: currentState.title,
        description: currentState.description,
        questions: currentState.questions,
        isEditMode: currentState.isEditMode,
        surveyId: currentState.surveyId,
      ),
    );

    final response = currentState.isEditMode && currentState.surveyId != null
        ? await _surveyRepository.updateSurvey(currentState.surveyId!, request)
        : await _surveyRepository.createSurvey(request);

    response.when(
      success: (survey, _) => emit(SurveyBuilderState.saved(survey)),
      error: (message, _) {
        // Check if it's a "has responses" error
        if (message.contains('atsakym') || message.contains('response')) {
          emit(
            SurveyBuilderState.editing(
              title: currentState.title,
              description: currentState.description,
              questions: currentState.questions,
              isEditMode: currentState.isEditMode,
              hasResponses: true,
              surveyId: currentState.surveyId,
              questionsError: message,
            ),
          );
        } else {
          emit(SurveyBuilderState.error(message));
        }
      },
    );
  }
}
