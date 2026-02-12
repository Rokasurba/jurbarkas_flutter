import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/patients/data/models/patient_advanced_filters.dart';
import 'package:frontend/patients/data/models/patient_list_item.dart';
import 'package:frontend/patients/data/models/patient_list_params.dart';
import 'package:frontend/patients/data/patients_repository.dart';

part 'patients_state.dart';
part 'patients_cubit.freezed.dart';

class PatientsCubit extends Cubit<PatientsState> {
  PatientsCubit({
    required PatientsRepository patientsRepository,
  })  : _patientsRepository = patientsRepository,
        super(const PatientsState.initial());

  final PatientsRepository _patientsRepository;
  Timer? _debounce;

  static const Duration _debounceDuration = Duration(milliseconds: 300);

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  Future<void> loadPatients() async {
    final params = state.params;
    emit(PatientsState.loading(params: params));

    final response = await _patientsRepository.getPatients(
      params: params,
    );

    response.when(
      success: (data, _) {
        emit(
          PatientsState.loaded(
            patients: data.patients,
            total: data.total,
            hasMore: data.hasMore,
            params: params,
          ),
        );
      },
      error: (message, _) => emit(PatientsState.error(message, params: params)),
    );
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! PatientsLoaded ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    emit(
      PatientsState.loaded(
        patients: currentState.patients,
        total: currentState.total,
        hasMore: currentState.hasMore,
        isLoadingMore: true,
        params: currentState.params,
      ),
    );

    final nextPageParams = PatientListParams.nextPage(
      currentState.patients.length,
      search: currentState.params.search,
      filter: currentState.params.filter,
      advancedFilters: currentState.params.advancedFilters,
    );

    final response = await _patientsRepository.getPatients(
      params: nextPageParams,
    );

    response.when(
      success: (data, _) {
        emit(
          PatientsState.loaded(
            patients: [...currentState.patients, ...data.patients],
            total: data.total,
            hasMore: data.hasMore,
            params: currentState.params,
          ),
        );
      },
      error: (message, _) {
        // On error, restore previous state without loading indicator
        emit(
          PatientsState.loaded(
            patients: currentState.patients,
            total: currentState.total,
            hasMore: currentState.hasMore,
            params: currentState.params,
          ),
        );
      },
    );
  }

  /// Searches patients with debounce (300ms delay).
  /// Clearing the search (empty query) is immediate, not debounced.
  void search(String query) {
    _debounce?.cancel();

    // Clear search immediately without debounce
    if (query.isEmpty) {
      unawaited(_performSearch(query));
      return;
    }

    _debounce = Timer(_debounceDuration, () {
      unawaited(_performSearch(query));
    });
  }

  Future<void> _performSearch(String query) async {
    final newParams = state.params.copyWith(
      search: query.isEmpty ? null : query,
      clearSearch: query.isEmpty,
      clearOffset: true,
    );
    await _loadWithParams(newParams);
  }

  /// Sets the filter and reloads patients.
  Future<void> setFilter(PatientFilter filter) async {
    final newParams = state.params.copyWith(filter: filter, clearOffset: true);
    await _loadWithParams(newParams);
  }

  /// Clears the search term and reloads (keeps filter).
  Future<void> clearSearch() async {
    final newParams = state.params.copyWith(clearSearch: true, clearOffset: true);
    await _loadWithParams(newParams);
  }

  /// Sets both status filter and advanced filters, then reloads.
  Future<void> applyFilters({
    required PatientFilter filter,
    PatientAdvancedFilters? advancedFilters,
  }) async {
    final newParams = state.params.copyWith(
      filter: filter,
      advancedFilters: advancedFilters,
      clearAdvancedFilters: advancedFilters == null,
      clearOffset: true,
    );
    await _loadWithParams(newParams);
  }

  /// Clears gender from advanced filters.
  Future<void> clearGenderFilter() async {
    final adv = state.params.advancedFilters;
    if (adv == null) return;
    final updated = adv.copyWith(gender: null);
    await _applyUpdatedAdvancedFilters(updated);
  }

  /// Clears BMI range from advanced filters.
  Future<void> clearBmiFilter() async {
    final adv = state.params.advancedFilters;
    if (adv == null) return;
    final updated = adv.copyWith(bmiMin: null, bmiMax: null);
    await _applyUpdatedAdvancedFilters(updated);
  }

  /// Clears systolic range from advanced filters.
  Future<void> clearSystolicFilter() async {
    final adv = state.params.advancedFilters;
    if (adv == null) return;
    final updated = adv.copyWith(systolicMin: null, systolicMax: null);
    await _applyUpdatedAdvancedFilters(updated);
  }

  /// Clears diastolic range from advanced filters.
  Future<void> clearDiastolicFilter() async {
    final adv = state.params.advancedFilters;
    if (adv == null) return;
    final updated = adv.copyWith(diastolicMin: null, diastolicMax: null);
    await _applyUpdatedAdvancedFilters(updated);
  }

  /// Clears blood sugar range from advanced filters.
  Future<void> clearSugarFilter() async {
    final adv = state.params.advancedFilters;
    if (adv == null) return;
    final updated = adv.copyWith(sugarMin: null, sugarMax: null);
    await _applyUpdatedAdvancedFilters(updated);
  }

  /// Clears the status filter back to 'all'.
  Future<void> clearStatusFilter() async {
    final newParams = state.params.copyWith(
      filter: PatientFilter.all,
      clearOffset: true,
    );
    await _loadWithParams(newParams);
  }

  Future<void> _applyUpdatedAdvancedFilters(
    PatientAdvancedFilters updated,
  ) async {
    final newParams = state.params.copyWith(
      advancedFilters: updated.hasActiveFilters ? updated : null,
      clearAdvancedFilters: !updated.hasActiveFilters,
      clearOffset: true,
    );
    await _loadWithParams(newParams);
  }

  /// Internal helper to load patients with given params.
  Future<void> _loadWithParams(PatientListParams params) async {
    emit(PatientsState.loading(params: params));

    final response = await _patientsRepository.getPatients(
      params: params,
    );

    response.when(
      success: (data, _) {
        emit(
          PatientsState.loaded(
            patients: data.patients,
            total: data.total,
            hasMore: data.hasMore,
            params: params,
          ),
        );
      },
      error: (message, _) => emit(PatientsState.error(message, params: params)),
    );
  }
}
