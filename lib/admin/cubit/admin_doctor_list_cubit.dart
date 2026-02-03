import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/admin/cubit/admin_doctor_list_state.dart';
import 'package:frontend/admin/data/admin_repository.dart';

class AdminDoctorListCubit extends Cubit<AdminDoctorListState> {
  AdminDoctorListCubit({
    required AdminRepository adminRepository,
  })  : _adminRepository = adminRepository,
        super(const AdminDoctorListState.initial());

  final AdminRepository _adminRepository;

  /// Load the first page of doctors.
  Future<void> loadDoctors() async {
    emit(const AdminDoctorListState.loading());

    final response = await _adminRepository.getDoctors();

    response.when(
      success: (paginatedResponse, _) {
        emit(AdminDoctorListState.loaded(
          doctors: paginatedResponse.data,
          currentPage: paginatedResponse.currentPage,
          lastPage: paginatedResponse.lastPage,
          total: paginatedResponse.total,
        ));
      },
      error: (message, _) {
        emit(AdminDoctorListState.error(message));
      },
    );
  }

  /// Load more doctors (next page) for infinite scroll.
  Future<void> loadMore() async {
    final currentState = state;

    if (currentState is! AdminDoctorListLoaded) return;
    if (currentState.isLoadingMore) return;
    if (!currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final response = await _adminRepository.getDoctors(page: nextPage);

    response.when(
      success: (paginatedResponse, _) {
        emit(AdminDoctorListState.loaded(
          doctors: [...currentState.doctors, ...paginatedResponse.data],
          currentPage: paginatedResponse.currentPage,
          lastPage: paginatedResponse.lastPage,
          total: paginatedResponse.total,
        ));
      },
      error: (message, _) {
        // On error during load more, keep current data but stop loading
        emit(currentState.copyWith(isLoadingMore: false));
      },
    );
  }

  /// Refresh the list from the first page.
  Future<void> refresh() async {
    await loadDoctors();
  }
}

extension AdminDoctorListLoadedExtension on AdminDoctorListLoaded {
  bool get hasMore => currentPage < lastPage;
}
