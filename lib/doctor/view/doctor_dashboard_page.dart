import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/auth/cubit/auth_cubit.dart';
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
    context.router.push(PatientProfileRoute(patientId: patientId));
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

  Future<void> _handleLogout(BuildContext context) async {
    await context.read<AuthCubit>().logout();
    if (context.mounted) {
      await context.router.replaceAll([const LoginRoute()]);
    }
  }

  void _onNewPatientTap(BuildContext context) {
    // TODO: Navigate to new patient registration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New patient registration coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ResponsiveBuilder(
      builder: (context, info) {
        final isMobile = info.isMobile;

        return ResponsiveScaffold(
          backgroundColor: Colors.white,
          drawer: isMobile ? _buildDrawer(context, l10n) : null,
          appBar: AppBar(
            backgroundColor: AppColors.secondary,
            elevation: 0,
            centerTitle: true,
            leading: isMobile
                ? Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      color: Colors.white,
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  )
                : null,
            title: Text(
              l10n.dataTitle,
              style: context.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: isMobile
                ? null
                : [
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.account_circle,
                            color: Colors.white,
                          ),
                          onSelected: (value) async {
                            if (value == 'logout') {
                              await _handleLogout(context);
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
                                    style: context.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    state.user?.email ?? '',
                                    style: context.bodySmall,
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
                  onPatientTap: (patientId) => _onPatientTap(context, patientId),
                ),
              ),
              // New patient button
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _onNewPatientTap(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.newPatient,
                        style: context.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, AppLocalizations l10n) {
    return Drawer(
      child: Column(
        children: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return Container(
                width: double.infinity,
                color: AppColors.secondary,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          child: Text(
                            state.user?.initials ?? '',
                            style: context.titleLarge?.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.user?.fullName ?? '',
                          style: context.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          state.user?.email ?? '',
                          style: context.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.message),
            title: Text(l10n.messagesLabel),
            onTap: () {
              Navigator.of(context).pop();
              context.router.push(const ConversationsRoute());
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.logoutButton),
            onTap: () async {
              Navigator.of(context).pop();
              await _handleLogout(context);
            },
          ),
          const SafeArea(
            top: false,
            child: SizedBox(height: 8),
          ),
        ],
      ),
    );
  }
}
