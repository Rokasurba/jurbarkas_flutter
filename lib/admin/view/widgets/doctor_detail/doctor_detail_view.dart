import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/admin/cubit/admin_doctor_detail_cubit.dart';
import 'package:frontend/admin/cubit/admin_doctor_detail_state.dart';
import 'package:frontend/admin/view/widgets/doctor_detail/doctor_action_buttons.dart';
import 'package:frontend/admin/view/widgets/doctor_detail/doctor_deactivate_dialog.dart';
import 'package:frontend/admin/view/widgets/doctor_detail/doctor_edit_dialog.dart';
import 'package:frontend/admin/view/widgets/doctor_detail/doctor_info_card.dart';
import 'package:frontend/auth/data/models/user_model.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';

class DoctorDetailView extends StatefulWidget {
  const DoctorDetailView({super.key});

  @override
  State<DoctorDetailView> createState() => _DoctorDetailViewState();
}

class _DoctorDetailViewState extends State<DoctorDetailView> {
  bool _hasChanges = false;

  void _handleBack() {
    unawaited(context.router.maybePop(_hasChanges));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDoctorDetailCubit, AdminDoctorDetailState>(
      builder: (context, state) {
        return state.when(
          initial: () => _DoctorDetailScaffold(
            onBack: _handleBack,
            body: const SizedBox.shrink(),
          ),
          loading: () => _DoctorDetailScaffold(
            onBack: _handleBack,
            body: const Center(child: CircularProgressIndicator()),
          ),
          loaded: (doctor, isUpdating) {
            return _DoctorLoadedView(
              doctor: doctor,
              isUpdating: isUpdating,
              onEdit: () => _handleEdit(doctor),
              onDeactivate: () => _handleDeactivate(doctor),
              onReactivate: _handleReactivate,
              onBack: _handleBack,
            );
          },
          error: (message) => _DoctorErrorView(
            message: message,
            onBack: _handleBack,
            onRetry: context.read<AdminDoctorDetailCubit>().loadDoctor,
          ),
        );
      },
    );
  }

  Future<void> _handleEdit(User doctor) async {
    final request = await DoctorEditDialog.show(context, doctor: doctor);
    if (request != null && mounted) {
      unawaited(context.read<AdminDoctorDetailCubit>().updateDoctor(request));
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _handleDeactivate(User doctor) async {
    final confirmed = await DoctorDeactivateDialog.show(
      context,
      doctor: doctor,
    );
    if (confirmed && mounted) {
      final success = await context
          .read<AdminDoctorDetailCubit>()
          .deactivateDoctor();
      if (success && mounted) {
        AppSnackbar.showSuccess(context, context.l10n.gydytojasDeaktyvuotas);
        setState(() => _hasChanges = true);
      }
    }
  }

  Future<void> _handleReactivate() async {
    final success = await context
        .read<AdminDoctorDetailCubit>()
        .reactivateDoctor();
    if (success && mounted) {
      AppSnackbar.showSuccess(context, context.l10n.gydytojasAktyvuotas);
      setState(() => _hasChanges = true);
    }
  }
}

class _DoctorDetailScaffold extends StatelessWidget {
  const _DoctorDetailScaffold({
    required this.onBack,
    required this.body,
  });

  final VoidCallback onBack;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        leading: BackButton(onPressed: onBack),
      ),
      body: body,
    );
  }
}

class _DoctorErrorView extends StatelessWidget {
  const _DoctorErrorView({
    required this.message,
    required this.onBack,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _DoctorDetailScaffold(
      onBack: onBack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message),
            const SizedBox(height: 16),
            AppButton.primary(
              label: l10n.retryButton,
              onPressed: onRetry,
              icon: Icons.refresh,
              expand: false,
              size: AppButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorLoadedView extends StatelessWidget {
  const _DoctorLoadedView({
    required this.doctor,
    required this.isUpdating,
    required this.onEdit,
    required this.onDeactivate,
    required this.onReactivate,
    required this.onBack,
  });

  final User doctor;
  final bool isUpdating;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;
  final VoidCallback onReactivate;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        leading: BackButton(onPressed: onBack),
        title: Text(
          doctor.fullName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: isUpdating ? null : onEdit,
            tooltip: l10n.editButton,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DoctorInfoCard(doctor: doctor),
            const SizedBox(height: 24),
            DoctorActionButtons(
              doctor: doctor,
              isUpdating: isUpdating,
              onDeactivate: onDeactivate,
              onReactivate: onReactivate,
            ),
          ],
        ),
      ),
    );
  }
}
