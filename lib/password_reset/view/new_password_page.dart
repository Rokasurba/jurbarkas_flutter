import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/password_reset/cubit/password_reset_cubit.dart';

@RoutePage()
class NewPasswordPage extends StatelessWidget {
  const NewPasswordPage({
    required this.cubit,
    super.key,
  });

  final PasswordResetCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: const NewPasswordView(),
    );
  }
}

class NewPasswordView extends StatefulWidget {
  const NewPasswordView({super.key});

  @override
  State<NewPasswordView> createState() => _NewPasswordViewState();
}

class _NewPasswordViewState extends State<NewPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      await context.read<PasswordResetCubit>().resetPassword(
            password: _passwordController.text,
            passwordConfirmation: _confirmPasswordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newPasswordTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: BlocConsumer<PasswordResetCubit, PasswordResetState>(
        listener: (context, state) async {
          await state.when(
            initial: () {},
            loading: () {},
            otpSent: (_) {},
            otpVerified: () {},
            success: (message) async {
              context.showSuccessSnackbar(message);
              await context.router.replaceAll([const LoginRoute()]);
            },
            error: (message) async {
              context.showErrorSnackbar(message);
              await context.read<PasswordResetCubit>().clearError();
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
                        Icons.lock_outline,
                        size: 80,
                        color: context.primaryColor,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.newPasswordTitle,
                        style: context.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.newPasswordSubtitle,
                        style: context.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      AppPasswordField(
                        controller: _passwordController,
                        labelText: l10n.newPasswordLabel,
                        textInputAction: TextInputAction.next,
                        enabled: !state.isLoading,
                      ),
                      const SizedBox(height: 16),
                      AppConfirmPasswordField(
                        controller: _confirmPasswordController,
                        passwordController: _passwordController,
                        onFieldSubmitted: (_) => _handleResetPassword(),
                        enabled: !state.isLoading,
                      ),
                      const SizedBox(height: 24),
                      AppButton.primary(
                        label: l10n.savePasswordButton,
                        onPressed:
                            state.isLoading ? null : _handleResetPassword,
                        isLoading: state.isLoading,
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
