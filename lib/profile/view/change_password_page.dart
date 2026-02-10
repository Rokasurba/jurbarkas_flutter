import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/profile/cubit/change_password_cubit.dart';
import 'package:frontend/profile/cubit/change_password_state.dart';
import 'package:frontend/profile/data/profile_repository.dart';

@RoutePage()
class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChangePasswordCubit(
        profileRepository: ProfileRepository(
          apiClient: context.read<ApiClient>(),
        ),
      ),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      await context.read<ChangePasswordCubit>().changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
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
          l10n.changePassword,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
        listener: (context, state) async {
          await state.whenOrNull(
            success: () async {
              context.showSuccessSnackbar(l10n.passwordChanged);
              await context.router.maybePop();
            },
            failure: (message) {
              context.showErrorSnackbar(message);
            },
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          return Center(
            child: SingleChildScrollView(
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
                        Icons.lock_open_outlined,
                        size: 80,
                        color: context.primaryColor,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.changePassword,
                        style: context.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.changePasswordSubtitle,
                        style: context.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _LabeledField(
                        label: l10n.currentPassword,
                        child: AppPasswordField(
                          controller: _currentPasswordController,
                          labelText: l10n.emailPlaceholder,
                          textInputAction: TextInputAction.next,
                          enabled: !isLoading,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.currentPasswordRequired;
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _LabeledField(
                        label: l10n.newPasswordLabel,
                        child: AppPasswordField(
                          controller: _newPasswordController,
                          labelText: l10n.emailPlaceholder,
                          textInputAction: TextInputAction.next,
                          enabled: !isLoading,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _LabeledField(
                        label: l10n.repeatNewPassword,
                        child: AppConfirmPasswordField(
                          controller: _confirmPasswordController,
                          passwordController: _newPasswordController,
                          onFieldSubmitted: (_) => _submit(),
                          enabled: !isLoading,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.passwordRequirementsHint,
                        style: context.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppButton.primary(
                        label: l10n.confirmButton,
                        onPressed: isLoading ? null : _submit,
                        isLoading: isLoading,
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

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
