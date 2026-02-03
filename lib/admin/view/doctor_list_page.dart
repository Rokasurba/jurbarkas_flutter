import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/admin/cubit/admin_doctor_list_cubit.dart';
import 'package:frontend/admin/cubit/admin_doctor_list_state.dart';
import 'package:frontend/admin/data/admin_repository.dart';
import 'package:frontend/auth/data/models/user_model.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:intl/intl.dart';

@RoutePage()
class DoctorListPage extends StatelessWidget {
  const DoctorListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminDoctorListCubit(
        adminRepository: AdminRepository(
          apiClient: context.read<ApiClient>(),
        ),
      )..loadDoctors(),
      child: const DoctorListView(),
    );
  }
}

class DoctorListView extends StatelessWidget {
  const DoctorListView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.gydytojuSarasas),
      ),
      body: BlocBuilder<AdminDoctorListCubit, AdminDoctorListState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (doctors, currentPage, lastPage, total, isLoadingMore) {
              if (doctors.isEmpty) {
                return Center(
                  child: Text(l10n.noDataYet),
                );
              }

              return RefreshIndicator(
                onRefresh: () => context.read<AdminDoctorListCubit>().refresh(),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification) {
                      final metrics = notification.metrics;
                      if (metrics.pixels >= metrics.maxScrollExtent - 200) {
                        context.read<AdminDoctorListCubit>().loadMore();
                      }
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: doctors.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == doctors.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final doctor = doctors[index];
                      return _DoctorCard(doctor: doctor);
                    },
                  ),
                ),
              );
            },
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<AdminDoctorListCubit>().loadDoctors(),
                    child: Text(l10n.retryButton),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.router.push(const DoctorFormRoute());
          if (result == true && context.mounted) {
            context.read<AdminDoctorListCubit>().refresh();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.naujasGydytojas),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor});

  final User doctor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: doctor.isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          child: Text(
            doctor.initials,
            style: TextStyle(
              color: doctor.isActive
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                doctor.fullName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _StatusBadge(isActive: doctor.isActive),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              doctor.email,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (doctor.phone != null && doctor.phone!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                doctor.phone!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (doctor.createdAt != null) ...[
              const SizedBox(height: 2),
              Text(
                dateFormat.format(doctor.createdAt!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final result = await context.router.push(
            DoctorDetailRoute(doctorId: doctor.id),
          );
          if (result == true && context.mounted) {
            context.read<AdminDoctorListCubit>().refresh();
          }
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isActive ? l10n.statusActive : l10n.statusInactive,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isActive ? Colors.green[700] : Colors.red[700],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
