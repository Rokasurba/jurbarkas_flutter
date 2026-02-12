import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:frontend/patients/data/patients_repository.dart';
import 'package:frontend/survey/cubit/survey_assignment_state.dart';
import 'package:frontend/survey/cubit/survey_builder_state.dart';
import 'package:frontend/survey/data/models/create_survey_request.dart';
import 'package:frontend/survey/data/models/question_form_data.dart';
import 'package:frontend/survey/data/survey_repository.dart';

class SurveyBuilderCubit extends Cubit<SurveyBuilderState> {
  SurveyBuilderCubit({
    required SurveyRepository surveyRepository,
    required PatientsRepository patientsRepository,
  })  : _surveyRepository = surveyRepository,
        _patientsRepository = patientsRepository,
        super(const SurveyBuilderState.initial());

  final SurveyRepository _surveyRepository;
  final PatientsRepository _patientsRepository;
  bool _patientsLoadedOnce = false;
  Timer? _searchDebounce;

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
            hasResponses: false,
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

  // --- Patient assignment methods ---

  /// Load patients for assignment (lazy-loaded on first tab switch).
  Future<void> loadPatients() async {
    final currentState = state;
    if (currentState is! SurveyBuilderEditing) return;
    if (_patientsLoadedOnce) return;

    emit(currentState.copyWith(patientsLoading: true, patientsError: null));

    final response = await _patientsRepository.getPatients();

    final latestState = state;
    if (latestState is! SurveyBuilderEditing) return;

    response.when(
      success: (patientsResponse, _) {
        _patientsLoadedOnce = true;
        final patients = patientsResponse.patients
            .map(
              (p) => PatientSelectionItem(patient: p),
            )
            .toList();

        // Pre-select all patients by default
        final preSelectedIds = patients
            .map((item) => item.patient.id)
            .toSet();

        emit(
          latestState.copyWith(
            allPatients: patients,
            filteredPatients: patients,
            selectedPatientIds: preSelectedIds,
            patientsLoading: false,
          ),
        );
      },
      error: (message, _) {
        emit(
          latestState.copyWith(
            patientsLoading: false,
            patientsError: message,
          ),
        );
      },
    );
  }

  /// Toggle patient selection.
  void togglePatient(int patientId) {
    final currentState = state;
    if (currentState is SurveyBuilderEditing) {
      final updatedSelection = Set<int>.from(currentState.selectedPatientIds);
      if (updatedSelection.contains(patientId)) {
        updatedSelection.remove(patientId);
      } else {
        updatedSelection.add(patientId);
      }
      emit(currentState.copyWith(selectedPatientIds: updatedSelection));
    }
  }

  /// Filter patients by search query (debounced 300ms).
  void searchPatients(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
      () => _applyPatientSearch(query),
    );
  }

  void _applyPatientSearch(String query) {
    final currentState = state;
    if (currentState is SurveyBuilderEditing) {
      final normalizedQuery = query.toLowerCase().trim();
      final filtered = normalizedQuery.isEmpty
          ? currentState.allPatients
          : currentState.allPatients.where((item) {
              final patient = item.patient;
              return patient.fullName
                      .toLowerCase()
                      .contains(normalizedQuery) ||
                  (patient.patientCode
                          ?.toLowerCase()
                          .contains(normalizedQuery) ??
                      false) ||
                  patient.email.toLowerCase().contains(normalizedQuery);
            }).toList();

      emit(
        currentState.copyWith(
          filteredPatients: filtered,
          patientSearchQuery: query,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }

  /// Select all visible patients.
  void selectAllPatients() {
    final currentState = state;
    if (currentState is SurveyBuilderEditing) {
      final allVisibleIds = currentState.filteredPatients
          .map((item) => item.patient.id)
          .toSet();
      // Merge with existing selections (keep non-visible ones selected too)
      final merged = {...currentState.selectedPatientIds, ...allVisibleIds};
      emit(currentState.copyWith(selectedPatientIds: merged));
    }
  }

  /// Deselect all patients.
  void deselectAllPatients() {
    final currentState = state;
    if (currentState is SurveyBuilderEditing) {
      emit(currentState.copyWith(selectedPatientIds: {}));
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

  /// Save the survey (create or update), then assign patients if selected.
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

    final selectedIds = currentState.selectedPatientIds;

    emit(
      SurveyBuilderState.saving(
        title: currentState.title,
        description: currentState.description,
        questions: currentState.questions,
        isEditMode: currentState.isEditMode,
        surveyId: currentState.surveyId,
        selectedPatientIds: selectedIds,
      ),
    );

    final response = currentState.isEditMode && currentState.surveyId != null
        ? await _surveyRepository.updateSurvey(currentState.surveyId!, request)
        : await _surveyRepository.createSurvey(request);

    await response.when(
      success: (survey, _) async {
        // If patients are selected, assign them
        if (selectedIds.isNotEmpty) {
          final assignResponse = await _surveyRepository.assignSurvey(
            surveyId: survey.id,
            patientIds: selectedIds.toList(),
          );
          // We still emit saved regardless of assignment result
          // (survey was created successfully)
          assignResponse.when(
            success: (result, message) {},
            error: (message, errors) {},
          );
        }
        emit(SurveyBuilderState.saved(survey));
      },
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
              allPatients: currentState.allPatients,
              filteredPatients: currentState.filteredPatients,
              selectedPatientIds: selectedIds,
              patientSearchQuery: currentState.patientSearchQuery,
            ),
          );
        } else {
          emit(SurveyBuilderState.error(message));
        }
      },
    );
  }
}
