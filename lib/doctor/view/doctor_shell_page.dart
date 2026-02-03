import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/auth/cubit/auth_cubit.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';

@RoutePage()
class DoctorShellPage extends StatelessWidget {
  const DoctorShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        DoctorDashboardRoute(),
        ConversationsRoute(),
        SurveyManagementRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return _DoctorShellView(
          tabsRouter: tabsRouter,
          child: child,
        );
      },
    );
  }
}

class _DoctorShellView extends StatelessWidget {
  const _DoctorShellView({
    required this.tabsRouter,
    required this.child,
  });

  final TabsRouter tabsRouter;
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
        if (info.isMobile) {
          return Scaffold(
            body: child,
            bottomNavigationBar: NavigationBar(
              selectedIndex: tabsRouter.activeIndex,
              onDestinationSelected: tabsRouter.setActiveIndex,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.dashboard_outlined),
                  selectedIcon: const Icon(Icons.dashboard),
                  label: l10n.dataTitle,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.message_outlined),
                  selectedIcon: const Icon(Icons.message),
                  label: l10n.messagesLabel,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.assignment_outlined),
                  selectedIcon: const Icon(Icons.assignment),
                  label: l10n.surveyListTitle,
                ),
              ],
            ),
          );
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
                icon: Icons.dashboard,
                label: l10n.dataTitle,
                selected: tabsRouter.activeIndex == 0,
                onTap: () => tabsRouter.setActiveIndex(0),
              ),
              _NavTile(
                icon: Icons.message,
                label: l10n.messagesLabel,
                selected: tabsRouter.activeIndex == 1,
                onTap: () => tabsRouter.setActiveIndex(1),
              ),
              _NavTile(
                icon: Icons.assignment,
                label: l10n.surveyListTitle,
                selected: tabsRouter.activeIndex == 2,
                onTap: () => tabsRouter.setActiveIndex(2),
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
