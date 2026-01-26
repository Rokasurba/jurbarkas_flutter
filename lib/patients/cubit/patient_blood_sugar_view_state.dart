part of 'patient_blood_sugar_view_cubit.dart';

@freezed
sealed class PatientBloodSugarViewState with _$PatientBloodSugarViewState {
  const PatientBloodSugarViewState._();

  const factory PatientBloodSugarViewState.initial() =
      _PatientBloodSugarViewInitial;

  const factory PatientBloodSugarViewState.loading() =
      _PatientBloodSugarViewLoading;

  const factory PatientBloodSugarViewState.loaded(
    List<BloodSugarReading> readings,
  ) = _PatientBloodSugarViewLoaded;

  const factory PatientBloodSugarViewState.failure(String message) =
      _PatientBloodSugarViewFailure;

  /// Get readings if in loaded state, otherwise empty list.
  List<BloodSugarReading> get readings => maybeWhen(
        loaded: (readings) => readings,
        orElse: () => [],
      );

  /// Whether data is currently loading.
  bool get isLoading => maybeWhen(
        loading: () => true,
        orElse: () => false,
      );
}
