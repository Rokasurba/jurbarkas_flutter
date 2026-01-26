import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/blood_pressure/data/models/blood_pressure_reading.dart';
import 'package:frontend/blood_sugar/data/models/blood_sugar_reading.dart';
import 'package:frontend/bmi/data/models/bmi_measurement.dart';
import 'package:frontend/patients/data/models/patient_health_data_params.dart';
import 'package:frontend/patients/data/patients_repository.dart';

part 'patient_metric_view_state.dart';
part 'patient_metric_view_cubit.freezed.dart';

/// Types of health metrics that can be viewed.
enum HealthMetricType { bloodPressure, bloodSugar, bmi }

/// Cubit for viewing a patient's health metric data (doctor/admin view).
/// Supports period filtering for graph display.
class PatientMetricViewCubit extends Cubit<PatientMetricViewState> {
  PatientMetricViewCubit({
    required PatientsRepository patientsRepository,
    required int patientId,
    required HealthMetricType metricType,
  })  : _patientsRepository = patientsRepository,
        _patientId = patientId,
        _metricType = metricType,
        super(const PatientMetricViewState.initial());

  final PatientsRepository _patientsRepository;
  final int _patientId;
  final HealthMetricType _metricType;
  DateTime? _currentFromDate;

  /// Load health data with optional date filter.
  Future<void> loadData({DateTime? fromDate}) async {
    _currentFromDate = fromDate;
    emit(const PatientMetricViewState.loading());

    final params = fromDate != null
        ? PatientHealthDataParams.fromDate(fromDate)
        : const PatientHealthDataParams.noFilter();

    final response = await _patientsRepository.getPatientHealthData(
      _patientId,
      params: params,
    );

    response.when(
      success: (data, _) {
        switch (_metricType) {
          case HealthMetricType.bloodPressure:
            emit(
              PatientMetricViewState.bloodPressureLoaded(data.bloodPressure),
            );
          case HealthMetricType.bloodSugar:
            emit(PatientMetricViewState.bloodSugarLoaded(data.bloodSugar));
          case HealthMetricType.bmi:
            emit(PatientMetricViewState.bmiLoaded(data.bmi));
        }
      },
      error: (message, _) {
        emit(PatientMetricViewState.failure(message));
      },
    );
  }

  /// Reload data with the current filter.
  Future<void> refresh() async {
    await loadData(fromDate: _currentFromDate);
  }
}
