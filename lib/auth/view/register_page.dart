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
        title: Text(l10n.registerTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
              final homeRoute =
                  context.read<AuthCubit>().getHomeRouteForRole();
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
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ResponsiveCard(
                maxWidth: 420,
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.person_add_outlined,
                        size: 64,
                        color: context.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.registerSubtitle,
                        style: context.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Name field
                      AppTextField(
                        controller: _nameController,
                        labelText: l10n.nameLabel,
                        prefixIcon: Icons.person_outline,
                        textCapitalization: TextCapitalization.words,
                        enabled: !state.isLoading,
                        validator: AppValidators.required(l10n.nameRequired),
                      ),
                      const SizedBox(height: 16),

                      // Surname field
                      AppTextField(
                        controller: _surnameController,
                        labelText: l10n.surnameLabel,
                        prefixIcon: Icons.person_outline,
                        textCapitalization: TextCapitalization.words,
                        enabled: !state.isLoading,
                        validator: AppValidators.required(l10n.surnameRequired),
                      ),
                      const SizedBox(height: 16),

                      // Email field
                      AppEmailField(
                        controller: _emailController,
                        enabled: !state.isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Phone field (optional)
                      AppTextField(
                        controller: _phoneController,
                        labelText: l10n.phoneLabel,
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        enabled: !state.isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      AppPasswordField(
                        controller: _passwordController,
                        textInputAction: TextInputAction.next,
                        enabled: !state.isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password field
                      AppConfirmPasswordField(
                        controller: _confirmPasswordController,
                        passwordController: _passwordController,
                        onFieldSubmitted: (_) => _handleRegister(),
                        enabled: !state.isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Privacy policy consent
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
                              CheckboxListTile(
                                value: _consentAccepted,
                                onChanged: state.isLoading
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _consentAccepted = value ?? false;
                                        });
                                        field.didChange(value);
                                      },
                                title: Text(
                                  l10n.privacyPolicyConsent,
                                  style: context.bodyMedium,
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              ),
                              if (field.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
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
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: state.isLoading ? null : _handleRegister,
                          child: state.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.registerButton),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Login link
                      TextButton(
                        onPressed: state.isLoading
                            ? null
                            : () async => context.router.maybePop(),
                        child: Text(l10n.alreadyHaveAccount),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
