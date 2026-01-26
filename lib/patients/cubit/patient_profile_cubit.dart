import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/patients/data/models/patient_profile.dart';
import 'package:frontend/patients/data/patients_repository.dart';

part 'patient_profile_state.dart';
part 'patient_profile_cubit.freezed.dart';

/// Cubit for managing patient profile page state.
/// Fetches and holds a single patient's detailed profile.
class PatientProfileCubit extends Cubit<PatientProfileState> {
  PatientProfileCubit({
    required PatientsRepository patientsRepository,
    required int patientId,
  })  : _patientsRepository = patientsRepository,
        _patientId = patientId,
        super(const PatientProfileState.initial());

  final PatientsRepository _patientsRepository;
  final int _patientId;

  /// Loads the patient profile from the API.
  Future<void> loadProfile() async {
    emit(const PatientProfileState.loading());

    final response = await _patientsRepository.getPatientById(_patientId);

    response.when(
      success: (profile, _) {
        emit(PatientProfileState.loaded(profile));
      },
      error: (message, _) {
        emit(PatientProfileState.failure(message));
      },
    );
  }

  /// Refreshes the patient profile.
  Future<void> refresh() async {
    await loadProfile();
  }
}
