import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/admin/cubit/admin_doctor_form_state.dart';
import 'package:frontend/admin/data/admin_repository.dart';
import 'package:frontend/admin/data/models/create_doctor_request.dart';
import 'package:frontend/admin/data/models/update_doctor_request.dart';

class AdminDoctorFormCubit extends Cubit<AdminDoctorFormState> {
  AdminDoctorFormCubit({
    required AdminRepository adminRepository,
  })  : _adminRepository = adminRepository,
        super(const AdminDoctorFormState.initial());

  final AdminRepository _adminRepository;

  /// Create a new doctor account.
  Future<void> createDoctor(CreateDoctorRequest request) async {
    emit(const AdminDoctorFormState.loading());

    final response = await _adminRepository.createDoctor(request);

    response.when(
      success: (createResponse, _) {
        emit(AdminDoctorFormState.success(
          user: createResponse.user,
          temporaryPassword: createResponse.temporaryPassword,
        ));
      },
      error: (message, _) {
        emit(AdminDoctorFormState.error(message));
      },
    );
  }

  /// Update an existing doctor's details.
  Future<void> updateDoctor(int id, UpdateDoctorRequest request) async {
    emit(const AdminDoctorFormState.loading());

    final response = await _adminRepository.updateDoctor(id, request);

    response.when(
      success: (user, _) {
        emit(AdminDoctorFormState.success(user: user));
      },
      error: (message, _) {
        emit(AdminDoctorFormState.error(message));
      },
    );
  }

  /// Deactivate a doctor account.
  Future<void> deactivateDoctor(int id) async {
    emit(const AdminDoctorFormState.loading());

    final response = await _adminRepository.deactivateDoctor(id);

    response.when(
      success: (data, message) {
        // Return a placeholder user since deactivate returns void
        emit(const AdminDoctorFormState.initial());
      },
      error: (message, _) {
        emit(AdminDoctorFormState.error(message));
      },
    );
  }

  /// Reactivate a doctor account.
  Future<void> reactivateDoctor(int id) async {
    emit(const AdminDoctorFormState.loading());

    final response = await _adminRepository.reactivateDoctor(id);

    response.when(
      success: (user, _) {
        emit(AdminDoctorFormState.success(user: user));
      },
      error: (message, _) {
        emit(AdminDoctorFormState.error(message));
      },
    );
  }

  /// Reset state to initial.
  void reset() {
    emit(const AdminDoctorFormState.initial());
  }
}
