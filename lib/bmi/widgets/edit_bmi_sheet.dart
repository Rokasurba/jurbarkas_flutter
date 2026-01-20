import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/bmi/data/models/bmi_measurement.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_primary_button.dart';
import 'package:frontend/l10n/l10n.dart';

class EditBmiSheet extends StatefulWidget {
  const EditBmiSheet({
    required this.measurement,
    required this.onUpdate,
    required this.isLoading,
    super.key,
  });

  final BmiMeasurement measurement;
  final void Function(int heightCm, double weightKg) onUpdate;
  final bool isLoading;

  static Future<void> show(
    BuildContext context, {
    required BmiMeasurement measurement,
    required void Function(int heightCm, double weightKg) onUpdate,
    required bool isLoading,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditBmiSheet(
        measurement: measurement,
        onUpdate: onUpdate,
        isLoading: isLoading,
      ),
    );
  }

  @override
  State<EditBmiSheet> createState() => _EditBmiSheetState();
}

class _EditBmiSheetState extends State<EditBmiSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  double? _calculatedBmi;

  @override
  void initState() {
    super.initState();
    _heightController =
        TextEditingController(text: widget.measurement.heightCm.toString());
    _weightController =
        TextEditingController(text: widget.measurement.weightKg);
    _heightController.addListener(_calculateBmi);
    _weightController.addListener(_calculateBmi);
    _calculateBmi();
  }

  @override
  void dispose() {
    _heightController.removeListener(_calculateBmi);
    _weightController.removeListener(_calculateBmi);
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _calculateBmi() {
    final heightText = _heightController.text;
    final weightText = _weightController.text.replaceAll(',', '.');

    final height = int.tryParse(heightText);
    final weight = double.tryParse(weightText);

    if (height != null &&
        height >= 50 &&
        height <= 250 &&
        weight != null &&
        weight >= 20 &&
        weight <= 300) {
      final heightM = height / 100;
      final bmi = weight / (heightM * heightM);
      setState(() {
        _calculatedBmi = double.parse(bmi.toStringAsFixed(2));
      });
    } else {
      setState(() {
        _calculatedBmi = null;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final heightCm = int.parse(_heightController.text);
      final weightKg = double.parse(
        _weightController.text.replaceAll(',', '.'),
      );
      widget.onUpdate(heightCm, weightKg);
    }
  }

  String? _validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.heightRequired;
    }
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 50 || parsed > 250) {
      return context.l10n.checkValues;
    }
    return null;
  }

  String? _validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.weightRequired;
    }
    final normalized = value.replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null || parsed < 20 || parsed > 300) {
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
              controller: _heightController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              decoration: InputDecoration(
                labelText: l10n.heightLabel,
                suffixText: l10n.cmUnit,
                helperText: l10n.heightRange,
              ),
              validator: _validateHeight,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                labelText: l10n.weightLabel,
                suffixText: l10n.kgUnit,
                helperText: l10n.weightRange,
              ),
              validator: _validateWeight,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            if (_calculatedBmi != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.yourBmi,
                      style: context.titleMedium?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _calculatedBmi!.toStringAsFixed(2),
                      style: context.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
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
