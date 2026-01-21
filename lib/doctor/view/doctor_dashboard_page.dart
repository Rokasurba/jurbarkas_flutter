import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/auth/cubit/auth_cubit.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/cubit/patients_cubit.dart';
import 'package:frontend/patients/data/patients_repository.dart';
import 'package:frontend/patients/widgets/patient_list_view.dart';

@RoutePage()
class DoctorDashboardPage extends StatelessWidget {
  const DoctorDashboardPage({super.key});

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
      child: const _DoctorDashboardView(),
    );
  }
}

class _DoctorDashboardView extends StatelessWidget {
  const _DoctorDashboardView();

  void _onPatientTap(BuildContext context, int patientId) {
    context.router.push(PatientProfileRoute(patientId: patientId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ResponsiveScaffold(
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
        actions: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle),
                onSelected: (value) async {
                  if (value == 'logout') {
                    await context.read<AuthCubit>().logout();
                    if (context.mounted) {
                      context.router.replaceAll([const LoginRoute()]);
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.user?.fullName ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          state.user?.email ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout),
                        const SizedBox(width: 8),
                        Text(l10n.logoutButton),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: PatientListView(
        onPatientTap: (patientId) => _onPatientTap(context, patientId),
      ),
    );
  }
}
