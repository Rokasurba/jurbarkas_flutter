import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/auth/cubit/auth_cubit.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';

@RoutePage()
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminDashboardView();
  }
}

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

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
            leading: isMobile
                ? Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  )
                : null,
            title: Text(
              l10n.appTitle,
              style: context.appBarTitle,
            ),
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
          body: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 80,
                      color: Colors.purple[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.welcomeMessage(state.user?.fullName ?? ''),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.roleAdmin,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      l10n.dashboardComingSoon,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
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
