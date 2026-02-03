import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/patients/data/models/patient_list_item.dart';

part 'survey_assignment_state.freezed.dart';

/// Item in the patient selection list for survey assignment.
class PatientSelectionItem {
  PatientSelectionItem({
    required this.patient,
    this.hasExistingAssignment = false,
  });

  final PatientListItem patient;
  final bool hasExistingAssignment;
}

@freezed
sealed class SurveyAssignmentState with _$SurveyAssignmentState {
  /// Initial state before loading.
  const factory SurveyAssignmentState.initial() = SurveyAssignmentInitial;

  /// Loading patients list.
  const factory SurveyAssignmentState.loading() = SurveyAssignmentLoading;

  /// Patients loaded and ready for selection.
  const factory SurveyAssignmentState.loaded({
    required List<PatientSelectionItem> allPatients,
    required List<PatientSelectionItem> filteredPatients,
    required Set<int> selectedIds,
    required int surveyId,
    required String searchQuery,
  }) = SurveyAssignmentLoaded;

  /// Assigning survey to selected patients.
  const factory SurveyAssignmentState.assigning({
    required Set<int> selectedIds,
    required int surveyId,
  }) = SurveyAssignmentAssigning;

  /// Successfully assigned survey.
  const factory SurveyAssignmentState.assigned({
    required int assignedCount,
    required int skippedCount,
  }) = SurveyAssignmentAssigned;

  /// Error state.
  const factory SurveyAssignmentState.error(String message) =
      SurveyAssignmentError;
}
