import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/auth/data/models/user_model.dart';

part 'admin_patient_detail_state.freezed.dart';

/// State for admin patient detail operations.
@freezed
sealed class AdminPatientDetailState with _$AdminPatientDetailState {
  const factory AdminPatientDetailState.initial() = AdminPatientDetailInitial;
  const factory AdminPatientDetailState.updating() = AdminPatientDetailUpdating;
  const factory AdminPatientDetailState.updateSuccess(User patient) =
      AdminPatientDetailUpdateSuccess;
  const factory AdminPatientDetailState.deactivated() =
      AdminPatientDetailDeactivated;
  const factory AdminPatientDetailState.reactivated(User patient) =
      AdminPatientDetailReactivated;
  const factory AdminPatientDetailState.error(String message) =
      AdminPatientDetailError;
}
