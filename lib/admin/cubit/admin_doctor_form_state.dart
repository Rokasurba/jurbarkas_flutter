import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/auth/data/models/user_model.dart';

part 'admin_doctor_form_state.freezed.dart';

@freezed
sealed class AdminDoctorFormState with _$AdminDoctorFormState {
  const factory AdminDoctorFormState.initial() = AdminDoctorFormInitial;

  const factory AdminDoctorFormState.loading() = AdminDoctorFormLoading;

  const factory AdminDoctorFormState.success({
    required User user,
    String? temporaryPassword,
  }) = AdminDoctorFormSuccess;

  const factory AdminDoctorFormState.error(String message) =
      AdminDoctorFormError;
}
