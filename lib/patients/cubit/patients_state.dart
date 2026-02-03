part of 'patients_cubit.dart';

@freezed
sealed class PatientsState with _$PatientsState {
  const PatientsState._();

  const factory PatientsState.initial() = PatientsInitial;
  const factory PatientsState.loading({
    @Default(PatientListParams.firstPage()) PatientListParams params,
  }) = PatientsLoading;
  const factory PatientsState.loaded({
    required List<PatientListItem> patients,
    required int total,
    required bool hasMore,
    @Default(false) bool isLoadingMore,
    @Default(PatientListParams.firstPage()) PatientListParams params,
  }) = PatientsLoaded;
  const factory PatientsState.error(
    String message, {
    @Default(PatientListParams.firstPage()) PatientListParams params,
  }) = PatientsError;

  bool get isLoading => this is PatientsLoading;

  List<PatientListItem> get patients => maybeWhen(
    loaded: (patients, total, hasMore, isLoadingMore, params) => patients,
    orElse: () => [],
  );

  int get total => maybeWhen(
    loaded: (patients, total, hasMore, isLoadingMore, params) => total,
    orElse: () => 0,
  );

  bool get hasMore => maybeWhen(
    loaded: (patients, total, hasMore, isLoadingMore, params) => hasMore,
    orElse: () => false,
  );

  bool get isLoadingMore => maybeWhen(
    loaded: (patients, total, hasMore, isLoadingMore, params) => isLoadingMore,
    orElse: () => false,
  );

  PatientListParams get params => maybeWhen(
    loading: (params) => params,
    loaded: (patients, total, hasMore, isLoadingMore, params) => params,
    error: (message, params) => params,
    orElse: PatientListParams.firstPage,
  );

  /// Returns true if search/filter is active.
  bool get hasActiveFilters => params.hasActiveFilters;
}
