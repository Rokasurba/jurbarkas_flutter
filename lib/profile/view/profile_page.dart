import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/auth/cubit/auth_cubit.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    await context.read<AuthCubit>().logout();
    if (context.mounted) {
      await context.router.replaceAll([const LoginRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        title: Text(
          l10n.profileTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state.user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.secondary,
                    child: Text(
                      user.initials,
                      style: context.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    user.fullName,
                    style: context.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    user.email,
                    style: context.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Personal Information Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.profileInfo,
                          style: context.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label: l10n.emailLabel,
                          value: user.email,
                        ),
                        if (user.phone != null) ...[
                          const Divider(),
                          _InfoRow(
                            icon: Icons.phone_outlined,
                            label: l10n.phone,
                            value: user.phone!,
                          ),
                        ],
                        if (user.dateOfBirth != null) ...[
                          const Divider(),
                          _InfoRow(
                            icon: Icons.cake_outlined,
                            label: l10n.dateOfBirth,
                            value: AppDateFormats.formatDateString(
                              user.dateOfBirth,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Settings Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.settings,
                          style: context.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _SettingsTile(
                          icon: Icons.lock_outline,
                          title: l10n.changePassword,
                          onTap: () =>
                              context.router.push(const ChangePasswordRoute()),
                        ),
                        const Divider(height: 1),
                        _SettingsTile(
                          icon: Icons.privacy_tip_outlined,
                          title: l10n.privacyPolicy,
                          onTap: () => context.router.push(
                            LegalDocumentRoute(
                              title: l10n.privacyPolicy,
                              documentType: 'privacy',
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        _SettingsTile(
                          icon: Icons.description_outlined,
                          title: l10n.termsAndConditions,
                          onTap: () => context.router.push(
                            LegalDocumentRoute(
                              title: l10n.termsAndConditions,
                              documentType: 'terms',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Logout button - now scrolls with content
                AppButton.dangerOutlined(
                  label: l10n.logoutButton,
                  icon: Icons.logout,
                  onPressed: () => unawaited(_handleLogout(context)),
                ),
                const SafeArea(
                  top: false,
                  child: SizedBox(height: 16),
                ),
              ],
            ),
          );
        },
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: context.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.secondary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
