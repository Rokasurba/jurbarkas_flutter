import 'package:bloc/bloc.dart';
import 'package:frontend/admin/admin.dart';

/// Cubit for admin patient detail operations (edit, deactivate, reactivate).
class AdminPatientDetailCubit extends Cubit<AdminPatientDetailState> {
  AdminPatientDetailCubit({
    required AdminRepository adminRepository,
  })  : _adminRepository = adminRepository,
        super(const AdminPatientDetailState.initial());

  final AdminRepository _adminRepository;

  /// Update patient details.
  Future<void> updatePatient(int id, UpdatePatientRequest request) async {
    emit(const AdminPatientDetailState.updating());

    final response = await _adminRepository.updatePatient(id, request);

    response.when(
      success: (patient, _) =>
          emit(AdminPatientDetailState.updateSuccess(patient)),
      error: (message, _) => emit(AdminPatientDetailState.error(message)),
    );
  }

  /// Deactivate a patient account.
  Future<void> deactivatePatient(int id) async {
    emit(const AdminPatientDetailState.updating());

    final response = await _adminRepository.deactivatePatient(id);

    response.when(
      success: (data, message) {
        emit(const AdminPatientDetailState.deactivated());
      },
      error: (message, _) => emit(AdminPatientDetailState.error(message)),
    );
  }

  /// Reactivate a patient account.
  Future<void> reactivatePatient(int id) async {
    emit(const AdminPatientDetailState.updating());

    final response = await _adminRepository.reactivatePatient(id);

    response.when(
      success: (patient, _) =>
          emit(AdminPatientDetailState.reactivated(patient)),
      error: (message, _) => emit(AdminPatientDetailState.error(message)),
    );
  }
}
