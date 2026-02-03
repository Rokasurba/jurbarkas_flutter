import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/auth/data/models/user_model.dart';

part 'admin_doctor_detail_state.freezed.dart';

@freezed
sealed class AdminDoctorDetailState with _$AdminDoctorDetailState {
  const factory AdminDoctorDetailState.initial() = AdminDoctorDetailInitial;

  const factory AdminDoctorDetailState.loading() = AdminDoctorDetailLoading;

  const factory AdminDoctorDetailState.loaded({
    required User doctor,
    @Default(false) bool isUpdating,
  }) = AdminDoctorDetailLoaded;

  const factory AdminDoctorDetailState.error(String message) =
      AdminDoctorDetailError;
}
