import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/auth/cubit/auth_cubit.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';

@RoutePage()
class AdminShellPage extends StatelessWidget {
  const AdminShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoRouter(
      builder: (context, child) {
        return _AdminShellView(child: child);
      },
    );
  }
}

class _AdminShellView extends StatelessWidget {
  const _AdminShellView({required this.child});

  final Widget child;

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
        // Mobile: no bottom nav, just show content
        if (info.isMobile) {
          return child;
        }

        // Desktop: permanent side navigation
        return Scaffold(
          body: Row(
            children: [
              _buildSideNavigation(context, l10n),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSideNavigation(BuildContext context, AppLocalizations l10n) {
    return Theme(
      data: Theme.of(context).copyWith(
        drawerTheme: const DrawerThemeData(
          shape: RoundedRectangleBorder(),
        ),
      ),
      child: SizedBox(
        width: 280,
        child: Drawer(
          backgroundColor: Colors.white,
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
              _NavTile(
                icon: Icons.admin_panel_settings,
                label: l10n.administravimas,
                selected: true,
                onTap: () {},
              ),
              const Spacer(),
              const Divider(),
              ListTile(
                tileColor: Colors.white,
                leading: const Icon(Icons.logout),
                title: Text(l10n.logoutButton),
                onTap: () => unawaited(_handleLogout(context)),
              ),
              const SafeArea(
                top: false,
                child: SizedBox(height: 8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: selected
          ? AppColors.secondary.withValues(alpha: 0.1)
          : Colors.white,
      leading: Icon(
        icon,
        color: selected ? AppColors.secondary : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? AppColors.secondary : null,
          fontWeight: selected ? FontWeight.bold : null,
        ),
      ),
      onTap: onTap,
    );
  }
}
