import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/password_reset/cubit/password_reset_cubit.dart';

@RoutePage()
class OtpVerificationPage extends StatelessWidget {
  const OtpVerificationPage({
    required this.cubit,
    super.key,
  });

  final PasswordResetCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: const OtpVerificationView(),
    );
  }
}

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({super.key});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpValue => _otpControllers.map((c) => c.text).join();

  bool get _isOtpComplete => _otpControllers.every((c) => c.text.isNotEmpty);

  Future<void> _handleVerify() async {
    if (_isOtpComplete) {
      await context.read<PasswordResetCubit>().verifyOtp(otp: _otpValue);
    }
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-submit when all 6 digits are entered
    if (_isOtpComplete) {
      unawaited(_handleVerify());
    }
  }

  void _clearOtpFields() {
    for (final controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PasswordResetCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.verifyCodeTitle),
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
            otpVerified: () async {
              await context.router.push(
                NewPasswordRoute(cubit: cubit),
              );
            },
            success: (_) {},
            error: (message) async {
              context.showErrorSnackbar(message);
              _clearOtpFields();
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
                        Icons.mail_outline,
                        size: 80,
                        color: context.primaryColor,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.verifyCodeTitle,
                        style: context.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.verifyCodeSubtitle(cubit.email),
                        style: context.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return AppOtpDigitField(
                            controller: _otpControllers[index],
                            focusNode: _focusNodes[index],
                            enabled: !state.isLoading,
                            onChanged: (value) => _onOtpChanged(index, value),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.otpExpiryHint,
                        style: context.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 56,
                        child: AppPrimaryButton(
                          onPressed: state.isLoading || !_isOtpComplete
                              ? null
                              : _handleVerify,
                          child: state.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.verifyButton),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () async {
                          await cubit.reset();
                          if (context.mounted) {
                            context.router
                                .popUntilRouteWithName(LoginRoute.name);
                          }
                        },
                        child: Text(l10n.cancelButton),
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
