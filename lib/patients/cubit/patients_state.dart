part of 'patients_cubit.dart';

@freezed
sealed class PatientsState with _$PatientsState {
  const PatientsState._();

  const factory PatientsState.initial() = PatientsInitial;
  const factory PatientsState.loading() = PatientsLoading;
  const factory PatientsState.loaded({
    required List<PatientListItem> patients,
    required int total,
    required bool hasMore,
    @Default(false) bool isLoadingMore,
  }) = PatientsLoaded;
  const factory PatientsState.error(String message) = PatientsError;

  bool get isLoading => this is PatientsLoading;

  List<PatientListItem> get patients => maybeWhen(
        loaded: (patients, _, __, ___) => patients,
        orElse: () => [],
      );

  int get total => maybeWhen(
        loaded: (_, total, __, ___) => total,
        orElse: () => 0,
      );

  bool get hasMore => maybeWhen(
        loaded: (_, __, hasMore, ___) => hasMore,
        orElse: () => false,
      );

  bool get isLoadingMore => maybeWhen(
        loaded: (_, __, ___, isLoadingMore) => isLoadingMore,
        orElse: () => false,
      );
}
