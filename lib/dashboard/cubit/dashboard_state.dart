part of 'dashboard_cubit.dart';

@freezed
sealed class DashboardState with _$DashboardState {
  const DashboardState._();

  const factory DashboardState.initial() = DashboardInitial;
  const factory DashboardState.loading() = DashboardLoading;
  const factory DashboardState.loaded(DashboardResponse data) = DashboardLoaded;
  const factory DashboardState.failure(String message) = DashboardFailure;

  bool get isLoading => this is DashboardLoading;

  DashboardResponse? get data => maybeWhen(
        loaded: (data) => data,
        orElse: () => null,
      );
}
