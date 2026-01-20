import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/blood_sugar/data/models/blood_sugar_reading.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_primary_button.dart';
import 'package:frontend/l10n/l10n.dart';

class EditBloodSugarSheet extends StatefulWidget {
  const EditBloodSugarSheet({
    required this.reading,
    required this.onUpdate,
    required this.isLoading,
    super.key,
  });

  final BloodSugarReading reading;
  final void Function(double glucoseLevel) onUpdate;
  final bool isLoading;

  static Future<void> show(
    BuildContext context, {
    required BloodSugarReading reading,
    required void Function(double glucoseLevel) onUpdate,
    required bool isLoading,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditBloodSugarSheet(
        reading: reading,
        onUpdate: onUpdate,
        isLoading: isLoading,
      ),
    );
  }

  @override
  State<EditBloodSugarSheet> createState() => _EditBloodSugarSheetState();
}

class _EditBloodSugarSheetState extends State<EditBloodSugarSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _glucoseController;

  @override
  void initState() {
    super.initState();
    _glucoseController =
        TextEditingController(text: widget.reading.glucoseLevel);
  }

  @override
  void dispose() {
    _glucoseController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final glucoseLevel = double.parse(
        _glucoseController.text.replaceAll(',', '.'),
      );
      widget.onUpdate(glucoseLevel);
    }
  }

  String? _validateGlucose(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.glucoseLevelRequired;
    }
    final normalized = value.replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null || parsed < 1.0 || parsed > 35.0) {
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
            TextFormField(
              controller: _glucoseController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                LengthLimitingTextInputFormatter(5),
              ],
              decoration: InputDecoration(
                labelText: l10n.glucoseLevelLabel,
                suffixText: l10n.mmolLUnit,
                helperText: l10n.glucoseLevelRange,
              ),
              validator: _validateGlucose,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        widget.isLoading ? null : () => Navigator.pop(context),
                    child: Text(l10n.cancelButton),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
