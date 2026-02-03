import 'package:flutter/foundation.dart';
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
        super(const AdminDoctorDetailState.initial()) {
    debugPrint('[AdminDoctorDetailCubit] Created for doctorId: $doctorId');
  }

  final AdminRepository _adminRepository;
  final int _doctorId;

  Future<void> loadDoctor() async {
    debugPrint('[AdminDoctorDetailCubit] loadDoctor() called');
    if (state is AdminDoctorDetailLoading) {
      debugPrint('[AdminDoctorDetailCubit] Already loading, returning');
      return;
    }
    debugPrint('[AdminDoctorDetailCubit] Emitting loading state');
    emit(const AdminDoctorDetailState.loading());

    debugPrint('[AdminDoctorDetailCubit] Calling repository.getDoctor()');
    final response = await _adminRepository.getDoctor(_doctorId);
    debugPrint('[AdminDoctorDetailCubit] Got response from repository');

    response.when(
      success: (doctor, _) {
        debugPrint('[AdminDoctorDetailCubit] Success! Doctor: ${doctor.id} - '
            '${doctor.fullName}');
        debugPrint('[AdminDoctorDetailCubit] Emitting loaded state...');
        emit(AdminDoctorDetailState.loaded(doctor: doctor));
        debugPrint('[AdminDoctorDetailCubit] Loaded state emitted');
      },
      error: (message, _) {
        debugPrint('[AdminDoctorDetailCubit] Error: $message');
        emit(AdminDoctorDetailState.error(message));
      },
    );
    debugPrint('[AdminDoctorDetailCubit] loadDoctor() completed');
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
      success: (_, __) {
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
