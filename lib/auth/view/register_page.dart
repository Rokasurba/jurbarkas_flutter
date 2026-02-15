import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/auth/cubit/auth_cubit.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';

@RoutePage()
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RegisterView();
  }
}

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _consentAccepted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      await context.read<AuthCubit>().register(
        name: _nameController.text.trim(),
        surname: _surnameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        consent: _consentAccepted,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.registerTitle,
          style: context.appBarTitle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async => context.router.maybePop(),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) async {
          await state.when(
            initial: () {},
            loading: () {},
            authenticated: (user) async {
              context.showSuccessSnackbar(l10n.registrationSuccess);
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
              final formContent = _buildForm(context, l10n, state);

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
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: formContent,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return formContent;
            },
          );
        },
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AppLocalizations l10n,
    AuthState state,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Name
                Text(
                  l10n.nameLabel,
                  style: context.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _nameController,
                  labelText: l10n.nameLabel,
                  textCapitalization: TextCapitalization.words,
                  enabled: !state.isLoading,
                  validator: AppValidators.required(l10n.nameRequired),
                ),
                const SizedBox(height: 16),

                // Surname
                Text(
                  l10n.surnameLabel,
                  style: context.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _surnameController,
                  labelText: l10n.surnameLabel,
                  textCapitalization: TextCapitalization.words,
                  enabled: !state.isLoading,
                  validator: AppValidators.required(l10n.surnameRequired),
                ),
                const SizedBox(height: 16),

                // Email
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

                // Phone (optional)
                Text(
                  l10n.phoneLabel,
                  style: context.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _phoneController,
                  labelText: l10n.phoneLabel,
                  keyboardType: TextInputType.phone,
                  enabled: !state.isLoading,
                ),
                const SizedBox(height: 16),

                // Password
                Text(
                  l10n.passwordLabel,
                  style: context.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                AppPasswordField(
                  controller: _passwordController,
                  textInputAction: TextInputAction.next,
                  enabled: !state.isLoading,
                ),
                const SizedBox(height: 16),

                // Confirm Password
                Text(
                  l10n.confirmPasswordLabel,
                  style: context.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                AppConfirmPasswordField(
                  controller: _confirmPasswordController,
                  passwordController: _passwordController,
                  onFieldSubmitted: (_) => _handleRegister(),
                  enabled: !state.isLoading,
                ),
                const SizedBox(height: 16),

                // Privacy policy consent with tappable link
                FormField<bool>(
                  initialValue: _consentAccepted,
                  validator: (value) {
                    if (value != true) {
                      return l10n.privacyPolicyRequired;
                    }
                    return null;
                  },
                  builder: (field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _consentAccepted,
                                onChanged: state.isLoading
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _consentAccepted = value ?? false;
                                        });
                                        field.didChange(value);
                                      },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Wrap(
                                  children: [
                                    Text(
                                      l10n.privacyPolicyConsentPrefix,
                                      style: context.bodyMedium,
                                    ),
                                    GestureDetector(
                                      // TODO(privacy): Open policy
                                      onTap: () {},
                                      child: Text(
                                        l10n.privacyPolicy.toLowerCase(),
                                        style: context.bodyMedium?.copyWith(
                                          color: AppColors.primary,
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(left: 36, top: 4),
                            child: Text(
                              field.errorText!,
                              style: context.bodySmall?.copyWith(
                                color: context.errorColor,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Register button
                AppButton.primary(
                  label: l10n.registerButton,
                  onPressed: state.isLoading ? null : _handleRegister,
                  isLoading: state.isLoading,
                ),
                const SizedBox(height: 16),

                // Login link
                AppButton.text(
                  label: l10n.alreadyHaveAccount,
                  onPressed: state.isLoading
                      ? null
                      : () async => context.router.maybePop(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
