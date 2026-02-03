import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
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

  @override
  Widget build(BuildContext context) {
    debugPrint('[DoctorDetailView] build() called');
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.router.maybePop(_hasChanges);
        }
      },
      child: BlocBuilder<AdminDoctorDetailCubit, AdminDoctorDetailState>(
        builder: (context, state) {
          debugPrint('[DoctorDetailView] BlocBuilder rebuilding, state: '
              '${state.runtimeType}');
          return state.when(
            initial: () {
              debugPrint('[DoctorDetailView] Rendering initial state');
              return _buildScaffold(body: const SizedBox.shrink());
            },
            loading: () {
              debugPrint('[DoctorDetailView] Rendering loading state');
              return _buildScaffold(
                body: const Center(child: CircularProgressIndicator()),
              );
            },
            loaded: (doctor, isUpdating) {
              debugPrint('[DoctorDetailView] Rendering loaded state for: '
                  '${doctor.fullName}');
              return _DoctorLoadedView(
                doctor: doctor,
                isUpdating: isUpdating,
                onEdit: () => _handleEdit(doctor),
                onDeactivate: () => _handleDeactivate(doctor),
                onReactivate: _handleReactivate,
              );
            },
            error: (message) {
              debugPrint('[DoctorDetailView] Rendering error state: $message');
              return _buildErrorView(message);
            },
          );
        },
      ),
    );
  }

  Widget _buildScaffold({required Widget body}) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),
      body: body,
    );
  }

  Widget _buildErrorView(String message) {
    final l10n = context.l10n;

    return _buildScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<AdminDoctorDetailCubit>().loadDoctor(),
              child: Text(l10n.retryButton),
            ),
          ],
        ),
      ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.gydytojasDeaktyvuotas)),
        );
        setState(() => _hasChanges = true);
      }
    }
  }

  Future<void> _handleReactivate() async {
    final success = await context
        .read<AdminDoctorDetailCubit>()
        .reactivateDoctor();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.gydytojasAktyvuotas)),
      );
      setState(() => _hasChanges = true);
    }
  }
}

class _DoctorLoadedView extends StatelessWidget {
  const _DoctorLoadedView({
    required this.doctor,
    required this.isUpdating,
    required this.onEdit,
    required this.onDeactivate,
    required this.onReactivate,
  });

  final User doctor;
  final bool isUpdating;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;
  final VoidCallback onReactivate;

  @override
  Widget build(BuildContext context) {
    debugPrint('[_DoctorLoadedView] build() START');
    final l10n = context.l10n;
    debugPrint('[_DoctorLoadedView] Got l10n');

    debugPrint('[_DoctorLoadedView] Building Scaffold...');
    final scaffold = Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
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
    debugPrint('[_DoctorLoadedView] build() END - returning Scaffold');
    return scaffold;
  }
}
