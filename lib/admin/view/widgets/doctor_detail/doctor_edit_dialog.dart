import 'package:flutter/material.dart';
import 'package:frontend/admin/data/models/update_doctor_request.dart';
import 'package:frontend/auth/data/models/user_model.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_text_field.dart';
import 'package:frontend/l10n/l10n.dart';

class DoctorEditDialog extends StatefulWidget {
  const DoctorEditDialog({required this.doctor, super.key});

  final User doctor;

  static Future<UpdateDoctorRequest?> show(
    BuildContext context, {
    required User doctor,
  }) {
    return showDialog<UpdateDoctorRequest>(
      context: context,
      builder: (context) => DoctorEditDialog(doctor: doctor),
    );
  }

  @override
  State<DoctorEditDialog> createState() => _DoctorEditDialogState();
}

class _DoctorEditDialogState extends State<DoctorEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.doctor.name);
    _surnameController = TextEditingController(text: widget.doctor.surname);
    _phoneController = TextEditingController(text: widget.doctor.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final request = UpdateDoctorRequest(
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim(),
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
    );

    Navigator.of(context).pop(request);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.editButton,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: _nameController,
                  labelText: l10n.nameLabel,
                  prefixIcon: Icons.person_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.nameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _surnameController,
                  labelText: l10n.surnameLabel,
                  prefixIcon: Icons.person_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.surnameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _phoneController,
                  labelText: l10n.phoneLabel,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppButton.outlined(
                        label: l10n.cancelButton,
                        onPressed: () => Navigator.of(context).pop(),
                        expand: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton.primary(
                        label: l10n.saveButton,
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
