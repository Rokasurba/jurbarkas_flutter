import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/blood_sugar/data/models/blood_sugar_reading.dart';
import 'package:frontend/patients/data/models/patient_health_data_params.dart';
import 'package:frontend/patients/data/patients_repository.dart';

part 'patient_blood_sugar_view_state.dart';
part 'patient_blood_sugar_view_cubit.freezed.dart';

/// Cubit for viewing a patient's blood sugar data (doctor/admin view).
/// Supports period filtering for graph display.
class PatientBloodSugarViewCubit extends Cubit<PatientBloodSugarViewState> {
  PatientBloodSugarViewCubit({
    required PatientsRepository patientsRepository,
    required int patientId,
  })  : _patientsRepository = patientsRepository,
        _patientId = patientId,
        super(const PatientBloodSugarViewState.initial());

  final PatientsRepository _patientsRepository;
  final int _patientId;
  DateTime? _currentFromDate;

  /// Load blood sugar data with optional date filter.
  Future<void> loadData({DateTime? fromDate}) async {
    _currentFromDate = fromDate;
    emit(const PatientBloodSugarViewState.loading());

    final params = fromDate != null
        ? PatientHealthDataParams.fromDate(fromDate)
        : const PatientHealthDataParams.noFilter();

    final response = await _patientsRepository.getPatientHealthData(
      _patientId,
      params: params,
    );

    response.when(
      success: (data, _) {
        emit(PatientBloodSugarViewState.loaded(data.bloodSugar));
      },
      error: (message, _) {
        emit(PatientBloodSugarViewState.failure(message));
      },
    );
  }

  /// Reload data with the current filter.
  Future<void> refresh() async {
    await loadData(fromDate: _currentFromDate);
  }
}
