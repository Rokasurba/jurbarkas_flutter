import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/password_reset/cubit/password_reset_cubit.dart';
import 'package:frontend/password_reset/data/password_reset_repository.dart';

@RoutePage()
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PasswordResetCubit(
        passwordResetRepository: context.read<PasswordResetRepository>(),
      ),
      child: const ForgotPasswordView(),
    );
  }
}

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    if (_formKey.currentState?.validate() ?? false) {
      await context.read<PasswordResetCubit>().sendOtp(
            email: _emailController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.forgotPasswordTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: BlocConsumer<PasswordResetCubit, PasswordResetState>(
        listener: (context, state) async {
          await state.when(
            initial: () {},
            loading: () {},
            otpSent: (message) async {
              context.showSuccessSnackbar(
                message.isNotEmpty ? message : l10n.otpSentMessage,
              );
              await context.router.push(
                OtpVerificationRoute(
                  cubit: context.read<PasswordResetCubit>(),
                ),
              );
            },
            otpVerified: () {},
            success: (_) {},
            error: (message) async {
              context.showErrorSnackbar(message);
              await context.read<PasswordResetCubit>().clearError();
            },
          );
        },
        builder: (context, state) {
          return ResponsiveBuilder(
            builder: (context, info) {
              final content = _buildContent(context, l10n, state);

              if (info.isDesktop || info.isTablet) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: content,
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

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    PasswordResetState state,
  ) {
    return SafeArea(
      child: Column(
        children: [
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
                      // Email icon
                      SvgPicture.asset(
                        Assets.mailIcon,
                        height: 92,
                        width: 86,
                      ),
                      const SizedBox(height: 24),
                      // Title
                      Text(
                        l10n.forgotPasswordTitle,
                        style: context.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      Text(
                        l10n.forgotPasswordSubtitle,
                        style: context.bodyLarge?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Email label
                      Text(
                        l10n.emailLabel,
                        style: context.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Email field
                      AppEmailField(
                        controller: _emailController,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleSendCode(),
                        enabled: !state.isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Bottom button
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AppButton.primary(
                label: l10n.sendCodeButton,
                onPressed: _handleSendCode,
                isLoading: state.isLoading,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
