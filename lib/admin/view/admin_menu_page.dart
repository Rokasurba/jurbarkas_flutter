import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/auth/cubit/auth_cubit.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';

@RoutePage()
class AdminMenuPage extends StatelessWidget {
  const AdminMenuPage({super.key});

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
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            title: Text(
              l10n.administravimoMeniu,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: info.isMobile
                ? [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () => unawaited(_handleLogout(context)),
                      tooltip: l10n.logoutButton,
                    ),
                  ]
                : null,
          ),
          body: ListView(
            children: [
              _AdminMenuTile(
                icon: Icons.medical_services_outlined,
                title: l10n.gydytojai,
                subtitle: l10n.gydytojuValdymas,
                onTap: () {
                  context.router.push(const DoctorListRoute());
                },
              ),
              _AdminMenuTile(
                icon: Icons.people_outline,
                title: l10n.pacientai,
                subtitle: l10n.pacientuValdymas,
                onTap: () {
                  context.router.push(const PatientsRoute());
                },
              ),
              _AdminMenuTile(
                icon: Icons.history,
                title: l10n.veiklosZurnalas,
                subtitle: l10n.gdprVeiklosIrasai,
                onTap: () {
                  context.router.push(const ActivityLogListRoute());
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdminMenuTile extends StatelessWidget {
  const _AdminMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 32, color: AppColors.primary),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
