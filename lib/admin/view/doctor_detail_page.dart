import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/admin/cubit/admin_doctor_form_cubit.dart';
import 'package:frontend/admin/cubit/admin_doctor_form_state.dart';
import 'package:frontend/admin/data/admin_repository.dart';
import 'package:frontend/admin/data/models/update_doctor_request.dart';
import 'package:frontend/auth/data/models/user_model.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:intl/intl.dart';

@RoutePage()
class DoctorDetailPage extends StatefulWidget {
  const DoctorDetailPage({
    super.key,
    @PathParam('doctorId') required this.doctorId,
  });

  final int doctorId;

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  User? _doctor;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDoctor();
  }

  Future<void> _loadDoctor() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repository = AdminRepository(apiClient: context.read<ApiClient>());
    final response = await repository.getDoctors();

    if (!mounted) return;

    response.when(
      success: (paginatedResponse, _) {
        final doctor = paginatedResponse.data.where(
          (d) => d.id == widget.doctorId,
        ).firstOrNull;

        setState(() {
          _doctor = doctor;
          _isLoading = false;
          if (doctor == null) {
            _error = context.l10n.gydytojasNerastas;
          }
        });
      },
      error: (message, _) {
        setState(() {
          _isLoading = false;
          _error = message;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _doctor == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error ?? l10n.gydytojasNerastas),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDoctor,
                child: Text(l10n.retryButton),
              ),
            ],
          ),
        ),
      );
    }

    return BlocProvider(
      create: (context) => AdminDoctorFormCubit(
        adminRepository: AdminRepository(
          apiClient: context.read<ApiClient>(),
        ),
      ),
      child: _DoctorDetailView(
        doctor: _doctor!,
        onDoctorUpdated: (updatedDoctor) {
          setState(() {
            _doctor = updatedDoctor;
          });
        },
        onDoctorDeactivated: () {
          setState(() {
            _doctor = _doctor!.copyWith(isActive: false);
          });
        },
        onDoctorReactivated: (updatedDoctor) {
          setState(() {
            _doctor = updatedDoctor;
          });
        },
      ),
    );
  }
}

class _DoctorDetailView extends StatefulWidget {
  const _DoctorDetailView({
    required this.doctor,
    required this.onDoctorUpdated,
    required this.onDoctorDeactivated,
    required this.onDoctorReactivated,
  });

  final User doctor;
  final ValueChanged<User> onDoctorUpdated;
  final VoidCallback onDoctorDeactivated;
  final ValueChanged<User> onDoctorReactivated;

  @override
  State<_DoctorDetailView> createState() => _DoctorDetailViewState();
}

class _DoctorDetailViewState extends State<_DoctorDetailView> {
  bool _hasChanges = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final doctor = widget.doctor;

    return BlocListener<AdminDoctorFormCubit, AdminDoctorFormState>(
      listener: (context, state) {
        state.whenOrNull(
          success: (user, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.gydytojasAtnaujintas)),
            );
            widget.onDoctorUpdated(user);
            setState(() => _hasChanges = true);
          },
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          },
        );
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            context.router.maybePop(_hasChanges);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(doctor.fullName),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditDialog(context, doctor),
                tooltip: l10n.editButton,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DoctorInfoCard(doctor: doctor),
                const SizedBox(height: 24),
                _ActionButtons(
                  doctor: doctor,
                  onDeactivate: () => _confirmDeactivate(context, doctor),
                  onReactivate: () => _reactivateDoctor(context, doctor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, User doctor) {
    final l10n = context.l10n;
    final nameController = TextEditingController(text: doctor.name);
    final surnameController = TextEditingController(text: doctor.surname);
    final phoneController = TextEditingController(text: doctor.phone ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.editButton),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.nameLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.nameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: surnameController,
                decoration: InputDecoration(
                  labelText: l10n.surnameLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.surnameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: l10n.phoneLabel,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;

              Navigator.of(dialogContext).pop();

              final request = UpdateDoctorRequest(
                name: nameController.text.trim(),
                surname: surnameController.text.trim(),
                phone: phoneController.text.trim().isNotEmpty
                    ? phoneController.text.trim()
                    : null,
              );

              context
                  .read<AdminDoctorFormCubit>()
                  .updateDoctor(doctor.id, request);
            },
            child: Text(l10n.saveButton),
          ),
        ],
      ),
    );
  }

  void _confirmDeactivate(BuildContext context, User doctor) {
    final l10n = context.l10n;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.arTikraiDeaktyvuoti),
        content: Text(
          '${doctor.fullName} (${doctor.email})',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _deactivateDoctor(context, doctor);
            },
            child: Text(l10n.confirmButton),
          ),
        ],
      ),
    );
  }

  Future<void> _deactivateDoctor(BuildContext context, User doctor) async {
    final l10n = context.l10n;
    final cubit = context.read<AdminDoctorFormCubit>();

    await cubit.deactivateDoctor(doctor.id);

    if (!mounted) return;

    final state = cubit.state;
    if (state is! AdminDoctorFormError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.gydytojasDeaktyvuotas)),
      );
      widget.onDoctorDeactivated();
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _reactivateDoctor(BuildContext context, User doctor) async {
    final l10n = context.l10n;
    final cubit = context.read<AdminDoctorFormCubit>();

    await cubit.reactivateDoctor(doctor.id);

    if (!mounted) return;

    final state = cubit.state;
    if (state is AdminDoctorFormSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.gydytojasAktyvuotas)),
      );
      widget.onDoctorReactivated(state.user);
      setState(() => _hasChanges = true);
    }
  }
}

class _DoctorInfoCard extends StatelessWidget {
  const _DoctorInfoCard({required this.doctor});

  final User doctor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: doctor.isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  child: Text(
                    doctor.initials,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: doctor.isActive
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.fullName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _StatusBadge(isActive: doctor.isActive),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _InfoRow(
              icon: Icons.email_outlined,
              label: l10n.emailLabel,
              value: doctor.email,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: l10n.phone,
              value: doctor.phone ?? l10n.notSpecified,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: l10n.registrationDate,
              value: doctor.createdAt != null
                  ? dateFormat.format(doctor.createdAt!)
                  : l10n.notSpecified,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ],
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

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.doctor,
    required this.onDeactivate,
    required this.onReactivate,
  });

  final User doctor;
  final VoidCallback onDeactivate;
  final VoidCallback onReactivate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocBuilder<AdminDoctorFormCubit, AdminDoctorFormState>(
      builder: (context, state) {
        final isLoading = state is AdminDoctorFormLoading;

        if (doctor.isActive) {
          return SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : onDeactivate,
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.person_off_outlined),
              label: Text(l10n.gydytojasDeaktyvuotas.replaceAll('Gydytojas deaktyvuotas', 'Deaktyvuoti')),
            ),
          );
        } else {
          return SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isLoading ? null : onReactivate,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.person_add_outlined),
              label: Text(l10n.gydytojasAktyvuotas.replaceAll('Gydytojas aktyvuotas', 'Aktyvuoti')),
            ),
          );
        }
      },
    );
  }
}
