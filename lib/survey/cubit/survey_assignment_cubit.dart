import 'package:bloc/bloc.dart';
import 'package:frontend/patients/data/patients_repository.dart';
import 'package:frontend/survey/cubit/survey_assignment_state.dart';
import 'package:frontend/survey/data/survey_repository.dart';

class SurveyAssignmentCubit extends Cubit<SurveyAssignmentState> {
  SurveyAssignmentCubit({
    required SurveyRepository surveyRepository,
    required PatientsRepository patientsRepository,
  })  : _surveyRepository = surveyRepository,
        _patientsRepository = patientsRepository,
        super(const SurveyAssignmentState.initial());

  final SurveyRepository _surveyRepository;
  final PatientsRepository _patientsRepository;
  int? _lastSurveyId;

  /// Reload patients using the last surveyId.
  Future<void> reload() async {
    if (_lastSurveyId != null) {
      await loadPatients(_lastSurveyId!);
    }
  }

  /// Load patients for assignment.
  Future<void> loadPatients(int surveyId) async {
    _lastSurveyId = surveyId;
    emit(const SurveyAssignmentState.loading());

    final response = await _patientsRepository.getPatients();

    response.when(
      success: (patientsResponse, _) {
        final patients = patientsResponse.patients
            .map(
              (p) => PatientSelectionItem(
                patient: p,
              ),
            )
            .toList();

        // Pre-select all non-assigned patients by default
        final preSelectedIds = patients
            .where((item) => !item.hasExistingAssignment)
            .map((item) => item.patient.id)
            .toSet();

        emit(
          SurveyAssignmentState.loaded(
            allPatients: patients,
            filteredPatients: patients,
            selectedIds: preSelectedIds,
            surveyId: surveyId,
            searchQuery: '',
          ),
        );
      },
      error: (message, _) {
        emit(SurveyAssignmentState.error(message));
      },
    );
  }

  /// Toggle patient selection.
  void togglePatient(int patientId) {
    final currentState = state;
    if (currentState is SurveyAssignmentLoaded) {
      final updatedSelection = Set<int>.from(currentState.selectedIds);
      if (updatedSelection.contains(patientId)) {
        updatedSelection.remove(patientId);
      } else {
        updatedSelection.add(patientId);
      }
      emit(currentState.copyWith(selectedIds: updatedSelection));
    }
  }

  /// Filter patients by search query.
  void searchPatients(String query) {
    final currentState = state;
    if (currentState is SurveyAssignmentLoaded) {
      final normalizedQuery = query.toLowerCase().trim();
      final filtered = normalizedQuery.isEmpty
          ? currentState.allPatients
          : currentState.allPatients.where((item) {
              final patient = item.patient;
              return patient.fullName.toLowerCase().contains(normalizedQuery) ||
                  (patient.patientCode
                          ?.toLowerCase()
                          .contains(normalizedQuery) ??
                      false) ||
                  patient.email.toLowerCase().contains(normalizedQuery);
            }).toList();

      emit(
        currentState.copyWith(
          filteredPatients: filtered,
          searchQuery: query,
        ),
      );
    }
  }

  /// Select all visible patients.
  void selectAll() {
    final currentState = state;
    if (currentState is SurveyAssignmentLoaded) {
      final allVisibleIds = currentState.filteredPatients
          .where((item) => !item.hasExistingAssignment)
          .map((item) => item.patient.id)
          .toSet();
      emit(currentState.copyWith(selectedIds: allVisibleIds));
    }
  }

  /// Deselect all patients.
  void deselectAll() {
    final currentState = state;
    if (currentState is SurveyAssignmentLoaded) {
      emit(currentState.copyWith(selectedIds: {}));
    }
  }

  /// Assign survey to selected patients.
  Future<void> assignToSelected() async {
    final currentState = state;
    if (currentState is! SurveyAssignmentLoaded) return;
    if (currentState.selectedIds.isEmpty) return;

    emit(
      SurveyAssignmentState.assigning(
        selectedIds: currentState.selectedIds,
        surveyId: currentState.surveyId,
      ),
    );

    final response = await _surveyRepository.assignSurvey(
      surveyId: currentState.surveyId,
      patientIds: currentState.selectedIds.toList(),
    );

    response.when(
      success: (result, _) {
        emit(
          SurveyAssignmentState.assigned(
            assignedCount: result.assignedCount,
            skippedCount: result.skippedCount,
          ),
        );
      },
      error: (message, _) {
        emit(SurveyAssignmentState.error(message));
      },
    );
  }
}
