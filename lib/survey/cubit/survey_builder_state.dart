import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/survey/data/models/question_form_data.dart';
import 'package:frontend/survey/data/models/survey.dart';

part 'survey_builder_state.freezed.dart';

@freezed
sealed class SurveyBuilderState with _$SurveyBuilderState {
  /// Initial state before data is loaded.
  const factory SurveyBuilderState.initial() = SurveyBuilderInitial;

  /// Loading state while fetching survey data for edit mode.
  const factory SurveyBuilderState.loading() = SurveyBuilderLoading;

  /// Active editing state with form data.
  const factory SurveyBuilderState.editing({
    required String title,
    required String? description,
    required List<QuestionFormData> questions,
    required bool isEditMode,
    required bool hasResponses,
    required int? surveyId,
    String? titleError,
    String? questionsError,
  }) = SurveyBuilderEditing;

  /// Saving state while submitting to API.
  const factory SurveyBuilderState.saving({
    required String title,
    required String? description,
    required List<QuestionFormData> questions,
    required bool isEditMode,
    required int? surveyId,
  }) = SurveyBuilderSaving;

  /// Success state after survey is saved.
  const factory SurveyBuilderState.saved(Survey survey) = SurveyBuilderSaved;

  /// Error state when something goes wrong.
  const factory SurveyBuilderState.error(String message) =
      SurveyBuilderError;
}
