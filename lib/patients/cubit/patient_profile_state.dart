part of 'patient_profile_cubit.dart';

/// State for the patient profile page.
/// Uses Freezed sealed union types as required by project architecture.
@freezed
sealed class PatientProfileState with _$PatientProfileState {
  const PatientProfileState._();

  /// Initial state - not yet loaded.
  const factory PatientProfileState.initial() = PatientProfileInitial;

  /// Loading state - fetching profile from API.
  const factory PatientProfileState.loading() = PatientProfileLoading;

  /// Loaded state - profile data available.
  const factory PatientProfileState.loaded(PatientProfile profile) =
      PatientProfileLoaded;

  /// Failure state - error occurred while loading.
  const factory PatientProfileState.failure(String message) =
      PatientProfileFailure;

  /// Returns true if currently loading.
  bool get isLoading => this is PatientProfileLoading;

  /// Returns the profile if loaded, null otherwise.
  PatientProfile? get profileOrNull => maybeWhen(
        loaded: (profile) => profile,
        orElse: () => null,
      );

  /// Returns the error message if in failure state, null otherwise.
  String? get errorOrNull => maybeWhen(
        failure: (message) => message,
        orElse: () => null,
      );
}
