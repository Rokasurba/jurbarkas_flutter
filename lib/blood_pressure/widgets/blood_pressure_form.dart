import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_primary_button.dart';
import 'package:frontend/l10n/l10n.dart';

class BloodPressureForm extends StatefulWidget {
  const BloodPressureForm({
    required this.onSubmit,
    required this.isLoading,
    super.key,
  });

  final void Function(int systolic, int diastolic) onSubmit;
  final bool isLoading;

  @override
  State<BloodPressureForm> createState() => _BloodPressureFormState();
}

class _BloodPressureFormState extends State<BloodPressureForm> {
  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final systolic = int.parse(_systolicController.text);
      final diastolic = int.parse(_diastolicController.text);
      widget.onSubmit(systolic, diastolic);
      _systolicController.clear();
      _diastolicController.clear();
    }
  }

  String? _validateSystolic(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.systolicRequired;
    }
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 60 || parsed > 250) {
      return context.l10n.checkValues;
    }
    return null;
  }

  String? _validateDiastolic(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.diastolicRequired;
    }
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 40 || parsed > 150) {
      return context.l10n.checkValues;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.bloodPressureNewSection,
            style: context.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.bloodPressureNewHint,
            style: context.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _systolicController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.systolicLabel,
                    suffixText: l10n.mmHgUnit,
                    helperText: l10n.systolicRange,
                  ),
                  validator: _validateSystolic,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  '/',
                  style: context.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.mainText,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _diastolicController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.diastolicLabel,
                    suffixText: l10n.mmHgUnit,
                    helperText: l10n.diastolicRange,
                  ),
                  validator: _validateDiastolic,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            child: AppPrimaryButton(
              onPressed: widget.isLoading ? null : _submit,
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.saveButton),
            ),
          ),
        ],
      ),
    );
  }
}
