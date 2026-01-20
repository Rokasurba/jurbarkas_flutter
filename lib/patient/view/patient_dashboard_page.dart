import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/auth/cubit/auth_cubit.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/dashboard/cubit/dashboard_cubit.dart';
import 'package:frontend/dashboard/data/repositories/dashboard_repository.dart';
import 'package:frontend/dashboard/widgets/metric_card.dart';
import 'package:frontend/dashboard/widgets/patient_profile_card.dart';
import 'package:frontend/l10n/l10n.dart';

@RoutePage()
class PatientDashboardPage extends StatelessWidget {
  const PatientDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = DashboardCubit(
          dashboardRepository: DashboardRepository(
            apiClient: context.read<ApiClient>(),
          ),
        );
        unawaited(cubit.loadDashboard());
        return cubit;
      },
      child: const PatientDashboardView(),
    );
  }
}

class PatientDashboardView extends StatelessWidget {
  const PatientDashboardView({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    await context.read<AuthCubit>().logout();
    if (context.mounted) {
      await context.router.replaceAll([const LoginRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ResponsiveBuilder(
      builder: (context, info) {
        final isMobile = info.isMobile;

        return ResponsiveScaffold(
          drawer: isMobile ? _buildDrawer(context, l10n) : null,
          appBar: AppBar(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            title: Text(l10n.dashboardTitle),
            leading: isMobile
                ? Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  )
                : null,
            actions: isMobile
                ? null
                : [
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return PopupMenuButton<String>(
                          icon: const Icon(Icons.account_circle),
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
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            loaded: (data) => RefreshIndicator(
              onRefresh: () => context.read<DashboardCubit>().refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PatientProfileCard(profile: data.user),
                    const SizedBox(height: 24),
                    Text(
                      l10n.mainIndicators,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mainText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    MetricCard(
                      title: l10n.bloodPressureTitle,
                      value: data.latestBloodPressure != null
                          ? '${data.latestBloodPressure!.systolic}/${data.latestBloodPressure!.diastolic}'
                          : null,
                      unit: data.latestBloodPressure != null
                          ? l10n.mmHgUnit
                          : null,
                      icon: Icons.favorite,
                      measuredAt: data.latestBloodPressure?.measuredAt,
                      onTap: () async {
                        await context.router.push(const BloodPressureRoute());
                        if (context.mounted) {
                          unawaited(
                            context.read<DashboardCubit>().refresh(),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    MetricCard(
                      title: l10n.bloodSugarTitle,
                      value: data.latestBloodSugar?.glucoseLevel,
                      unit: data.latestBloodSugar != null
                          ? l10n.mmolLUnit
                          : null,
                      icon: Icons.water_drop,
                      measuredAt: data.latestBloodSugar?.measuredAt,
                      onTap: () async {
                        await context.router.push(const BloodSugarRoute());
                        if (context.mounted) {
                          unawaited(
                            context.read<DashboardCubit>().refresh(),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    MetricCard(
                      title: l10n.bmiTitle,
                      value: data.latestBmi?.bmiValue,
                      icon: Icons.monitor_weight,
                      measuredAt: data.latestBmi?.measuredAt,
                      onTap: () async {
                        await context.router.push(const BmiRoute());
                        if (context.mounted) {
                          unawaited(
                            context.read<DashboardCubit>().refresh(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            failure: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    message,
                    style: TextStyle(color: context.errorColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<DashboardCubit>().loadDashboard(),
                    child: Text(l10n.retryButton),
                  ),
                ],
              ),
            ),
          );
        },
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
