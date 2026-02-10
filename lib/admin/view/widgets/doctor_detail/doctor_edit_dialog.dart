import 'package:flutter/material.dart';
import 'package:frontend/admin/data/models/update_doctor_request.dart';
import 'package:frontend/auth/data/models/user_model.dart';
import 'package:frontend/core/widgets/app_button.dart';
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

    return AlertDialog(
      title: Text(l10n.editButton),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: l10n.phoneLabel,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        AppButton.text(
          label: l10n.cancelButton,
          onPressed: () => Navigator.of(context).pop(),
          size: AppButtonSize.small,
        ),
        AppButton.primary(
          label: l10n.saveButton,
          onPressed: _submit,
          expand: false,
          size: AppButtonSize.small,
        ),
      ],
    );
  }
}
