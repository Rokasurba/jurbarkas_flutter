import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/auth/cubit/auth_cubit.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:package_info_plus/package_info_plus.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginView();
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      await context.read<AuthCubit>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  void _showDevLoginSelector() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _DevLoginSelector(
        onUserSelected: (email, password) {
          Navigator.pop(context);
          _emailController.text = email;
          _passwordController.text = password;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) async {
          await state.when(
            initial: () {},
            loading: () {},
            authenticated: (user) async {
              final homeRoute = context.read<AuthCubit>().getHomeRouteForRole();
              await context.router.replaceAll([homeRoute]);
            },
            unauthenticated: () {},
            error: (message) {
              context.showErrorSnackbar(message);
              context.read<AuthCubit>().clearError();
            },
          );
        },
        builder: (context, state) {
          return ResponsiveBuilder(
            builder: (context, info) {
              final content = Column(
                children: [
                  // Blue header with logo (extends into status bar)
                  const _LoginHeader(),
                  // Form content
                  Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 32),
                                Text(
                                  l10n.loginTitle,
                                  style: context.headlineMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                Text(
                                  l10n.emailLabel,
                                  style: context.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                AppEmailField(
                                  controller: _emailController,
                                  enabled: !state.isLoading,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.passwordLabel,
                                  style: context.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                AppPasswordField(
                                  controller: _passwordController,
                                  onFieldSubmitted: (_) => _handleLogin(),
                                  enabled: !state.isLoading,
                                  validator: AppValidators.required(
                                    l10n.passwordRequired,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () async {
                                      await context.router.push(
                                        const ForgotPasswordRoute(),
                                      );
                                    },
                                    child: Text(
                                      l10n.forgotPassword,
                                      style: context.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Bottom buttons with safe area for home indicator
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppPrimaryButton(
                              onPressed: _handleLogin,
                              isLoading: state.isLoading,
                              child: Text(l10n.loginButton),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.noAccountQuestion,
                                  style: context.bodyMedium?.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    await context.router.push(
                                      const RegisterRoute(),
                                    );
                                  },
                                  child: Text(
                                    l10n.registerLink,
                                    style: context.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const _AppVersionText(),
                                if (AppConfig.isDevelopment) ...[
                                  const SizedBox(width: 8),
                                  _DevLoginButton(
                                    onPressed: _showDevLoginSelector,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );

              // On web/desktop, center in a floating card
              if (info.isDesktop || info.isTablet) {
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            blurRadius: 40,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _buildWebContent(context, l10n, state),
                      ),
                    ),
                  ),
                );
              }

              return content;
            },
          );
        },
      ),
    );
  }
}

extension _LoginViewHelpers on _LoginViewState {
  Widget _buildWebContent(
    BuildContext context,
    AppLocalizations l10n,
    AuthState state,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo banner with rounded top corners
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Image.asset(
            Assets.logoLoginHeader,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
        // Form content
        Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.loginTitle,
                  style: context.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.emailLabel,
                  style: context.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                AppEmailField(
                  controller: _emailController,
                  enabled: !state.isLoading,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.passwordLabel,
                  style: context.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                AppPasswordField(
                  controller: _passwordController,
                  onFieldSubmitted: (_) => _handleLogin(),
                  enabled: !state.isLoading,
                  validator: AppValidators.required(l10n.passwordRequired),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () async {
                      await context.router.push(const ForgotPasswordRoute());
                    },
                    child: Text(
                      l10n.forgotPassword,
                      style: context.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppPrimaryButton(
                  onPressed: _handleLogin,
                  isLoading: state.isLoading,
                  child: Text(l10n.loginButton),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.noAccountQuestion,
                      style: context.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await context.router.push(const RegisterRoute());
                      },
                      child: Text(
                        l10n.registerLink,
                        style: context.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _AppVersionText(),
                    if (AppConfig.isDevelopment) ...[
                      const SizedBox(width: 8),
                      _DevLoginButton(onPressed: _showDevLoginSelector),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Column(
      children: [
        // Status bar area with matching color
        ColoredBox(
          color: AppColors.secondary,
          child: SizedBox(
            height: topPadding,
            width: double.infinity,
          ),
        ),
        // Logo image - fills width to avoid seams
        Image.asset(
          Assets.logoLoginHeader,
          fit: BoxFit.fitWidth,
          width: double.infinity,
        ),
      ],
    );
  }
}

class _AppVersionText extends StatelessWidget {
  const _AppVersionText();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '';
        if (version.isEmpty) return const SizedBox.shrink();
        return Text(
          'v$version',
          style: context.bodySmall?.copyWith(
            color: AppColors.secondaryText.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}

/// Button to open dev login selector (only shown in development).
class _DevLoginButton extends StatelessWidget {
  const _DevLoginButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.developer_mode, size: 16),
      label: const Text('Dev'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.secondaryText.withValues(alpha: 0.6),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        visualDensity: VisualDensity.compact,
        textStyle: context.bodySmall,
      ),
    );
  }
}

/// Bottom sheet selector for dev login users.
class _DevLoginSelector extends StatelessWidget {
  const _DevLoginSelector({required this.onUserSelected});

  final void Function(String email, String password) onUserSelected;

  static const _devUsers = [
    _DevUser(
      label: 'Admin',
      email: 'admin@jurbarkas.lt',
      password: 'password',
      icon: Icons.admin_panel_settings,
      color: Colors.red,
    ),
    _DevUser(
      label: 'Doctor',
      email: 'doctor@jurbarkas.lt',
      password: 'password',
      icon: Icons.medical_services,
      color: Colors.blue,
    ),
    _DevUser(
      label: 'Patient (Petras)',
      email: 'petras@jurbarkas.lt',
      password: 'password',
      icon: Icons.person,
      color: Colors.green,
    ),
    _DevUser(
      label: 'Patient (Ona)',
      email: 'ona@jurbarkas.lt',
      password: 'password',
      icon: Icons.person,
      color: Colors.teal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Dev Login',
              style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Select a test user to auto-fill credentials',
              style: context.bodySmall?.copyWith(
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ..._devUsers.map(
              (user) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _DevUserTile(
                  user: user,
                  onTap: () => onUserSelected(user.email, user.password),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DevUser {
  const _DevUser({
    required this.label,
    required this.email,
    required this.password,
    required this.icon,
    required this.color,
  });

  final String label;
  final String email;
  final String password;
  final IconData icon;
  final Color color;
}

class _DevUserTile extends StatelessWidget {
  const _DevUserTile({required this.user, required this.onTap});

  final _DevUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: user.color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: user.color.withValues(alpha: 0.2),
                child: Icon(user.icon, color: user.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.label,
                      style: context.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      user.email,
                      style: context.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
