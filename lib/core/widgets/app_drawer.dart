import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/auth/cubit/auth_cubit.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';

/// A navigation item for the app drawer.
class DrawerNavItem {
  const DrawerNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// Shared app drawer widget for consistent navigation across pages.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    required this.items,
    required this.isMobile,
    super.key,
  });

  /// Navigation items to display in the drawer.
  final List<DrawerNavItem> items;

  /// Whether the app is in mobile mode (affects drawer close behavior).
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Drawer(
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
          ...items.map(
            (item) => ListTile(
              tileColor: Colors.white,
              leading: Icon(item.icon),
              title: Text(item.label),
              onTap: () {
                _closeDrawerIfMobile(context);
                item.onTap();
              },
            ),
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            tileColor: Colors.white,
            leading: const Icon(Icons.logout),
            title: Text(l10n.logoutButton),
            onTap: () async {
              _closeDrawerIfMobile(context);
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

  void _closeDrawerIfMobile(BuildContext context) {
    if (isMobile) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    await context.read<AuthCubit>().logout();
    if (context.mounted) {
      await context.router.replaceAll([const LoginRoute()]);
    }
  }
}

/// Builds a patient drawer with standard navigation items.
Widget buildPatientDrawer(BuildContext context, {required bool isMobile}) {
  final l10n = context.l10n;
  final router = context.router;

  return AppDrawer(
    isMobile: isMobile,
    items: [
      DrawerNavItem(
        icon: Icons.dashboard,
        label: l10n.dashboardTitle,
        onTap: () => unawaited(
          router.replaceAll([const PatientDashboardRoute()]),
        ),
      ),
      DrawerNavItem(
        icon: Icons.message,
        label: l10n.messagesLabel,
        onTap: () => router.push(const ConversationsRoute()),
      ),
      DrawerNavItem(
        icon: Icons.notifications,
        label: l10n.remindersLabel,
        onTap: () => router.push(const RemindersRoute()),
      ),
      DrawerNavItem(
        icon: Icons.assignment,
        label: l10n.surveyListTitle,
        onTap: () => router.push(const MySurveysRoute()),
      ),
    ],
  );
}

/// Builds a doctor drawer with standard navigation items.
Widget buildDoctorDrawer(BuildContext context, {required bool isMobile}) {
  final l10n = context.l10n;
  final router = context.router;

  return AppDrawer(
    isMobile: isMobile,
    items: [
      DrawerNavItem(
        icon: Icons.dashboard,
        label: l10n.dataTitle,
        onTap: () => unawaited(
          router.replaceAll([const DoctorDashboardRoute()]),
        ),
      ),
      DrawerNavItem(
        icon: Icons.message,
        label: l10n.messagesLabel,
        onTap: () => router.push(const ConversationsRoute()),
      ),
      DrawerNavItem(
        icon: Icons.assignment,
        label: l10n.surveyListTitle,
        onTap: () => router.push(const SurveyManagementRoute()),
      ),
    ],
  );
}

/// Builds an admin drawer with standard navigation items.
Widget buildAdminDrawer(BuildContext context, {required bool isMobile}) {
  final l10n = context.l10n;
  final router = context.router;

  return AppDrawer(
    isMobile: isMobile,
    items: [
      DrawerNavItem(
        icon: Icons.admin_panel_settings,
        label: l10n.administravimas,
        onTap: () => unawaited(
          router.replaceAll([const AdminShellRoute()]),
        ),
      ),
    ],
  );
}
