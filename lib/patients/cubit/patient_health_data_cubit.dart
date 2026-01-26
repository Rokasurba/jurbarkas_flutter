import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/blood_pressure/data/models/blood_pressure_reading.dart';
import 'package:frontend/blood_sugar/data/models/blood_sugar_reading.dart';
import 'package:frontend/bmi/data/models/bmi_measurement.dart';
import 'package:frontend/patients/data/models/patient_health_data_params.dart';
import 'package:frontend/patients/data/patients_repository.dart';

part 'patient_health_data_state.dart';
part 'patient_health_data_cubit.freezed.dart';

/// Cubit for managing patient health data (doctor/admin view).
/// Fetches blood pressure, BMI, and blood sugar data for a specific patient.
class PatientHealthDataCubit extends Cubit<PatientHealthDataState> {
  PatientHealthDataCubit({
    required PatientsRepository patientsRepository,
    required int patientId,
  })  : _patientsRepository = patientsRepository,
        _patientId = patientId,
        super(const PatientHealthDataState.initial());

  final PatientsRepository _patientsRepository;
  final int _patientId;

  /// Loads all health data for the patient in a single API call.
  Future<void> loadHealthData({
    PatientHealthDataParams params = const PatientHealthDataParams.noFilter(),
  }) async {
    emit(const PatientHealthDataState.loading());

    final response = await _patientsRepository.getPatientHealthData(
      _patientId,
      params: params,
    );

    response.when(
      success: (data, _) => emit(PatientHealthDataState.loaded(
        bloodPressure: data.bloodPressure,
        bmi: data.bmi,
        bloodSugar: data.bloodSugar,
      )),
      error: (message, _) => emit(PatientHealthDataState.failure(message)),
    );
  }

  /// Refreshes all health data.
  Future<void> refresh({
    PatientHealthDataParams params = const PatientHealthDataParams.noFilter(),
  }) async {
    await loadHealthData(params: params);
  }
}
