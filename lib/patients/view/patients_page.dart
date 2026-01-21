import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/cubit/patients_cubit.dart';
import 'package:frontend/patients/data/patients_repository.dart';
import 'package:frontend/patients/widgets/patient_list_view.dart';

@RoutePage()
class PatientsPage extends StatelessWidget {
  const PatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = PatientsCubit(
          patientsRepository: PatientsRepository(
            apiClient: context.read<ApiClient>(),
          ),
        );
        unawaited(cubit.loadPatients());
        return cubit;
      },
      child: const _PatientsView(),
    );
  }
}

class _PatientsView extends StatelessWidget {
  const _PatientsView();

  void _onPatientTap(BuildContext context, int patientId) {
    context.router.push(PatientProfileRoute(patientId: patientId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        title: BlocBuilder<PatientsCubit, PatientsState>(
          builder: (context, state) {
            final total = state.total;
            return Text(
              total > 0
                  ? l10n.patientsCount(total)
                  : l10n.patientsTitle,
              style: context.appBarTitle,
            );
          },
        ),
      ),
      body: PatientListView(
        onPatientTap: (patientId) => _onPatientTap(context, patientId),
      ),
    );
  }
}
