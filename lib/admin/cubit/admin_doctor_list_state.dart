import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/auth/data/models/user_model.dart';

part 'admin_doctor_list_state.freezed.dart';

@freezed
sealed class AdminDoctorListState with _$AdminDoctorListState {
  const factory AdminDoctorListState.initial() = AdminDoctorListInitial;

  const factory AdminDoctorListState.loading() = AdminDoctorListLoading;

  const factory AdminDoctorListState.loaded({
    required List<User> doctors,
    required int currentPage,
    required int lastPage,
    required int total,
    @Default(false) bool isLoadingMore,
  }) = AdminDoctorListLoaded;

  const factory AdminDoctorListState.error(String message) =
      AdminDoctorListError;
}
