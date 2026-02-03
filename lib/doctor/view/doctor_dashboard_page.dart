import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/cubit/patients_cubit.dart';
import 'package:frontend/patients/data/models/patient_list_params.dart';
import 'package:frontend/patients/data/patients_repository.dart';
import 'package:frontend/patients/widgets/patient_filter_modal.dart';
import 'package:frontend/patients/widgets/patient_list_view.dart';
import 'package:frontend/patients/widgets/patient_search_header.dart';

@RoutePage()
class DoctorDashboardPage extends StatelessWidget {
  const DoctorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = PatientsCubit(
          patientsRepository: context.read<PatientsRepository>(),
        );
        unawaited(cubit.loadPatients());
        return cubit;
      },
      child: const _DoctorDashboardView(),
    );
  }
}

class _DoctorDashboardView extends StatelessWidget {
  const _DoctorDashboardView();

  void _onPatientTap(BuildContext context, int patientId) {
    unawaited(context.router.push(PatientProfileRoute(patientId: patientId)));
  }

  Future<void> _showFilterModal(BuildContext context) async {
    final cubit = context.read<PatientsCubit>();
    final currentFilter = cubit.state.params.filter;

    final selectedFilter = await showPatientFilterModal(
      context: context,
      currentFilter: currentFilter,
    );

    if (selectedFilter != null && selectedFilter != currentFilter) {
      unawaited(cubit.setFilter(selectedFilter));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.dataTitle,
          style: context.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          BlocBuilder<PatientsCubit, PatientsState>(
            buildWhen: (previous, current) =>
                previous.params != current.params,
            builder: (context, state) {
              final params = state.params;
              return PatientSearchHeader(
                initialSearch: params.search,
                hasActiveFilter: params.filter != PatientFilter.all,
                onSearchChanged: (query) {
                  context.read<PatientsCubit>().search(query);
                },
                onFilterTap: () => _showFilterModal(context),
              );
            },
          ),
          Expanded(
            child: PatientListView(
              onPatientTap: (patientId) =>
                  _onPatientTap(context, patientId),
            ),
          ),
        ],
      ),
    );
  }
}
