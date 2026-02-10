import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/admin/cubit/admin_doctor_detail_state.dart';
import 'package:frontend/admin/data/admin_repository.dart';
import 'package:frontend/admin/data/models/update_doctor_request.dart';

class AdminDoctorDetailCubit extends Cubit<AdminDoctorDetailState> {
  AdminDoctorDetailCubit({
    required AdminRepository adminRepository,
    required int doctorId,
  })  : _adminRepository = adminRepository,
        _doctorId = doctorId,
        super(const AdminDoctorDetailState.initial());

  final AdminRepository _adminRepository;
  final int _doctorId;

  Future<void> loadDoctor() async {
    if (state is AdminDoctorDetailLoading) return;
    emit(const AdminDoctorDetailState.loading());

    final response = await _adminRepository.getDoctor(_doctorId);

    response.when(
      success: (doctor, _) {
        emit(AdminDoctorDetailState.loaded(doctor: doctor));
      },
      error: (message, _) {
        emit(AdminDoctorDetailState.error(message));
      },
    );
  }

  Future<void> updateDoctor(UpdateDoctorRequest request) async {
    final currentState = state;
    if (currentState is! AdminDoctorDetailLoaded) return;

    emit(AdminDoctorDetailState.loaded(
      doctor: currentState.doctor,
      isUpdating: true,
    ));

    final response = await _adminRepository.updateDoctor(_doctorId, request);

    response.when(
      success: (user, _) {
        emit(AdminDoctorDetailState.loaded(doctor: user));
      },
      error: (message, _) {
        emit(AdminDoctorDetailState.loaded(doctor: currentState.doctor));
      },
    );
  }

  Future<bool> deactivateDoctor() async {
    final currentState = state;
    if (currentState is! AdminDoctorDetailLoaded) return false;

    emit(AdminDoctorDetailState.loaded(
      doctor: currentState.doctor,
      isUpdating: true,
    ));

    final response = await _adminRepository.deactivateDoctor(_doctorId);

    return response.when(
      success: (data, message) {
        final updatedDoctor = currentState.doctor.copyWith(isActive: false);
        emit(AdminDoctorDetailState.loaded(doctor: updatedDoctor));
        return true;
      },
      error: (message, _) {
        emit(AdminDoctorDetailState.loaded(doctor: currentState.doctor));
        return false;
      },
    );
  }

  Future<bool> reactivateDoctor() async {
    final currentState = state;
    if (currentState is! AdminDoctorDetailLoaded) return false;

    emit(AdminDoctorDetailState.loaded(
      doctor: currentState.doctor,
      isUpdating: true,
    ));

    final response = await _adminRepository.reactivateDoctor(_doctorId);

    return response.when(
      success: (user, _) {
        emit(AdminDoctorDetailState.loaded(doctor: user));
        return true;
      },
      error: (message, _) {
        emit(AdminDoctorDetailState.loaded(doctor: currentState.doctor));
        return false;
      },
    );
  }
}
