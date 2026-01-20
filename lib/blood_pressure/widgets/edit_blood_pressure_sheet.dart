import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/blood_pressure/data/models/blood_pressure_reading.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_primary_button.dart';
import 'package:frontend/l10n/l10n.dart';

class EditBloodPressureSheet extends StatefulWidget {
  const EditBloodPressureSheet({
    required this.reading,
    required this.onUpdate,
    required this.isLoading,
    super.key,
  });

  final BloodPressureReading reading;
  final void Function(int systolic, int diastolic) onUpdate;
  final bool isLoading;

  static Future<void> show(
    BuildContext context, {
    required BloodPressureReading reading,
    required void Function(int systolic, int diastolic) onUpdate,
    required bool isLoading,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => EditBloodPressureSheet(
        reading: reading,
        onUpdate: onUpdate,
        isLoading: isLoading,
      ),
    );
  }

  @override
  State<EditBloodPressureSheet> createState() => _EditBloodPressureSheetState();
}

class _EditBloodPressureSheetState extends State<EditBloodPressureSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _systolicController;
  late final TextEditingController _diastolicController;

  @override
  void initState() {
    super.initState();
    _systolicController =
        TextEditingController(text: widget.reading.systolic.toString());
    _diastolicController =
        TextEditingController(text: widget.reading.diastolic.toString());
  }

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
      widget.onUpdate(systolic, diastolic);
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

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.editEntry,
              style: context.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
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
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed:
                          widget.isLoading ? null : () => Navigator.pop(context),
                      child: Text(l10n.cancelButton),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 48,
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
                          : Text(l10n.updateButton),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
