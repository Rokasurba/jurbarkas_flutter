import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/bmi/data/models/bmi_measurement.dart';
import 'package:frontend/patients/data/models/patient_health_data_params.dart';
import 'package:frontend/patients/data/patients_repository.dart';

part 'patient_bmi_view_state.dart';
part 'patient_bmi_view_cubit.freezed.dart';

/// Cubit for viewing a patient's BMI data (doctor/admin view).
/// Supports period filtering for graph display.
class PatientBmiViewCubit extends Cubit<PatientBmiViewState> {
  PatientBmiViewCubit({
    required PatientsRepository patientsRepository,
    required int patientId,
  })  : _patientsRepository = patientsRepository,
        _patientId = patientId,
        super(const PatientBmiViewState.initial());

  final PatientsRepository _patientsRepository;
  final int _patientId;
  DateTime? _currentFromDate;

  /// Load BMI data with optional date filter.
  Future<void> loadData({DateTime? fromDate}) async {
    _currentFromDate = fromDate;
    emit(const PatientBmiViewState.loading());

    final params = fromDate != null
        ? PatientHealthDataParams.fromDate(fromDate)
        : const PatientHealthDataParams.noFilter();

    final response = await _patientsRepository.getPatientHealthData(
      _patientId,
      params: params,
    );

    response.when(
      success: (data, _) {
        emit(PatientBmiViewState.loaded(data.bmi));
      },
      error: (message, _) {
        emit(PatientBmiViewState.failure(message));
      },
    );
  }

  /// Reload data with the current filter.
  Future<void> refresh() async {
    await loadData(fromDate: _currentFromDate);
  }
}
