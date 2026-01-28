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
    loaded: (patients, _, __, ___, ____) => patients,
    orElse: () => [],
  );

  int get total => maybeWhen(
    loaded: (_, total, __, ___, ____) => total,
    orElse: () => 0,
  );

  bool get hasMore => maybeWhen(
    loaded: (_, __, hasMore, ___, ____) => hasMore,
    orElse: () => false,
  );

  bool get isLoadingMore => maybeWhen(
    loaded: (_, __, ___, isLoadingMore, ____) => isLoadingMore,
    orElse: () => false,
  );

  PatientListParams get params => maybeWhen(
    loading: (params) => params,
    loaded: (_, __, ___, ____, params) => params,
    error: (_, params) => params,
    orElse: PatientListParams.firstPage,
  );

  /// Returns true if search/filter is active.
  bool get hasActiveFilters => params.hasActiveFilters;
}
