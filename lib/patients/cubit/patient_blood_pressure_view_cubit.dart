import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/blood_pressure/data/models/blood_pressure_reading.dart';
import 'package:frontend/patients/data/models/patient_health_data_params.dart';
import 'package:frontend/patients/data/patients_repository.dart';

part 'patient_blood_pressure_view_state.dart';
part 'patient_blood_pressure_view_cubit.freezed.dart';

/// Cubit for viewing a patient's blood pressure data (doctor/admin view).
/// Supports period filtering for graph display.
class PatientBloodPressureViewCubit
    extends Cubit<PatientBloodPressureViewState> {
  PatientBloodPressureViewCubit({
    required PatientsRepository patientsRepository,
    required int patientId,
  })  : _patientsRepository = patientsRepository,
        _patientId = patientId,
        super(const PatientBloodPressureViewState.initial());

  final PatientsRepository _patientsRepository;
  final int _patientId;
  DateTime? _currentFromDate;

  /// Load blood pressure data with optional date filter.
  Future<void> loadData({DateTime? fromDate}) async {
    _currentFromDate = fromDate;
    emit(const PatientBloodPressureViewState.loading());

    final params = fromDate != null
        ? PatientHealthDataParams.fromDate(fromDate)
        : const PatientHealthDataParams.noFilter();

    final response = await _patientsRepository.getPatientHealthData(
      _patientId,
      params: params,
    );

    response.when(
      success: (data, _) {
        emit(PatientBloodPressureViewState.loaded(data.bloodPressure));
      },
      error: (message, _) {
        emit(PatientBloodPressureViewState.failure(message));
      },
    );
  }

  /// Reload data with the current filter.
  Future<void> refresh() async {
    await loadData(fromDate: _currentFromDate);
  }
}
