import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/patients/data/models/patient_list_item.dart';
import 'package:frontend/patients/data/patients_repository.dart';

part 'patients_state.dart';
part 'patients_cubit.freezed.dart';

class PatientsCubit extends Cubit<PatientsState> {
  PatientsCubit({
    required PatientsRepository patientsRepository,
  })  : _patientsRepository = patientsRepository,
        super(const PatientsState.initial());

  final PatientsRepository _patientsRepository;

  static const int _pageSize = 20;

  Future<void> loadPatients() async {
    emit(const PatientsState.loading());

    final response = await _patientsRepository.getPatients(
      limit: _pageSize,
    );

    response.when(
      success: (data, _) {
        emit(
          PatientsState.loaded(
            patients: data.patients,
            total: data.total,
            hasMore: data.hasMore,
          ),
        );
      },
      error: (message, _) => emit(PatientsState.error(message)),
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
      ),
    );

    final response = await _patientsRepository.getPatients(
      limit: _pageSize,
      offset: currentState.patients.length,
    );

    response.when(
      success: (data, _) {
        emit(
          PatientsState.loaded(
            patients: [...currentState.patients, ...data.patients],
            total: data.total,
            hasMore: data.hasMore,
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
          ),
        );
      },
    );
  }
}
