import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/profile/cubit/change_password_state.dart';
import 'package:frontend/profile/data/profile_repository.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit({
    required ProfileRepository profileRepository,
  })  : _profileRepository = profileRepository,
        super(const ChangePasswordState.initial());

  final ProfileRepository _profileRepository;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(const ChangePasswordState.loading());

    final response = await _profileRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    response.when(
      success: (_, message) => emit(const ChangePasswordState.success()),
      error: (message, errors) => emit(ChangePasswordState.failure(message)),
    );
  }
}
