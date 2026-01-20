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
  // TODO(dev): Remove test credentials before production
  final _emailController = TextEditingController(text: 'pacientas@test.lt');
  final _passwordController = TextEditingController(text: 'password123');

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
              final content = SafeArea(
                child: Column(
                  children: [
                    // Blue header with logo
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
                    // Bottom buttons
                    Padding(
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
                                  await context.router
                                      .push(const RegisterRoute());
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
                          const _AppVersionText(),
                        ],
                      ),
                    ),
                  ],
                ),
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
                            spreadRadius: 0,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            blurRadius: 16,
                            spreadRadius: 0,
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
            Assets.logoBanner,
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
                const _AppVersionText(),
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
    return Image.asset(
      Assets.logoBanner,
      fit: BoxFit.cover,
      width: double.infinity,
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
