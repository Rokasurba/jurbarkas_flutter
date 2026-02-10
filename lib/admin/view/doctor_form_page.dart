import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/admin/cubit/admin_doctor_form_cubit.dart';
import 'package:frontend/admin/cubit/admin_doctor_form_state.dart';
import 'package:frontend/admin/data/admin_repository.dart';
import 'package:frontend/admin/data/models/create_doctor_request.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';

@RoutePage()
class DoctorFormPage extends StatelessWidget {
  const DoctorFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminDoctorFormCubit(
        adminRepository: AdminRepository(
          apiClient: context.read<ApiClient>(),
        ),
      ),
      child: const DoctorFormView(),
    );
  }
}

class DoctorFormView extends StatefulWidget {
  const DoctorFormView({super.key});

  @override
  State<DoctorFormView> createState() => _DoctorFormViewState();
}

class _DoctorFormViewState extends State<DoctorFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final request = CreateDoctorRequest(
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
    );

    unawaited(context.read<AdminDoctorFormCubit>().createDoctor(request));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        title: Text(
          l10n.naujasGydytojas,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocConsumer<AdminDoctorFormCubit, AdminDoctorFormState>(
        listener: (context, state) {
          state.whenOrNull(
            success: (user, tempPassword) {
              if (tempPassword != null) {
                _showSuccessDialog(context, user.email, tempPassword);
              }
            },
            error: (message) {
              AppSnackbar.showError(context, message);
            },
          );
        },
        builder: (context, state) {
          final isLoading = state is AdminDoctorFormLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.nameLabel,
                      border: const OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.nameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _surnameController,
                    decoration: InputDecoration(
                      labelText: l10n.surnameLabel,
                      border: const OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.surnameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n.emailLabel,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.emailRequired;
                      }
                      if (!_isValidEmail(value.trim())) {
                        return l10n.emailInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: l10n.phoneLabel,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 32),
                  AppButton.primary(
                    label: l10n.saveButton,
                    onPressed: isLoading ? null : _submit,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }

  void _showSuccessDialog(
    BuildContext context,
    String email,
    String tempPassword,
  ) {
    final l10n = context.l10n;

    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.gydytojasSukurtas),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.prisijungimoDuomenysIssiusti),
            const SizedBox(height: 16),
            Text(
              '${l10n.emailLabel}: $email',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l10n.laikinasSlaptazodis}: $tempPassword',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    unawaited(
                      Clipboard.setData(ClipboardData(text: tempPassword)),
                    );
                    AppSnackbar.showInfo(context, l10n.copiedToClipboard);
                  },
                  tooltip: l10n.copyTooltip,
                ),
              ],
            ),
          ],
        ),
        actions: [
          AppButton.primary(
            label: l10n.ok,
            onPressed: () {
              Navigator.of(dialogContext).pop();
              unawaited(context.router.maybePop(true));
            },
            expand: false,
            size: AppButtonSize.small,
          ),
        ],
      ),
    ));
  }
}
