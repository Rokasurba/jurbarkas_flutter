import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/dashboard/data/models/dashboard_response.dart';
import 'package:frontend/dashboard/data/repositories/dashboard_repository.dart';

part 'dashboard_state.dart';
part 'dashboard_cubit.freezed.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required DashboardRepository dashboardRepository,
  })  : _dashboardRepository = dashboardRepository,
        super(const DashboardState.initial());

  final DashboardRepository _dashboardRepository;

  Future<void> loadDashboard() async {
    emit(const DashboardState.loading());

    final response = await _dashboardRepository.getDashboard();

    response.when(
      success: (data, _) => emit(DashboardState.loaded(data)),
      error: (message, _) => emit(DashboardState.failure(message)),
    );
  }

  Future<void> refresh() async {
    final response = await _dashboardRepository.getDashboard();

    response.when(
      success: (data, _) => emit(DashboardState.loaded(data)),
      error: (message, _) => emit(DashboardState.failure(message)),
    );
  }
}
