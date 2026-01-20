import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bmi/cubit/bmi_cubit.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';

class BmiForm extends StatefulWidget {
  const BmiForm({
    required this.onSubmit,
    required this.isLoading,
    super.key,
  });

  final void Function(int heightCm, double weightKg, DateTime measuredAt)
      onSubmit;
  final bool isLoading;

  @override
  BmiFormState createState() => BmiFormState();
}

class BmiFormState extends State<BmiForm> with DateTimePickerMixin {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  double? _calculatedBmi;

  @override
  void initState() {
    super.initState();
    initDateTime();
    _heightController.addListener(_calculateBmi);
    _weightController.addListener(_calculateBmi);
  }

  @override
  void dispose() {
    _heightController.removeListener(_calculateBmi);
    _weightController.removeListener(_calculateBmi);
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void clearForm() {
    _heightController.clear();
    _weightController.clear();
    _formKey.currentState?.reset();
    resetDateTime();
    setState(() {
      _calculatedBmi = null;
    });
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
      widget.onSubmit(heightCm, weightKg, combinedDateTime);
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

    return BlocListener<BmiCubit, BmiState>(
      listenWhen: (previous, current) => current is BmiSaved,
      listener: (context, state) => clearForm(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.bmiNewSection,
              style: context.sectionHeader,
            ),
            const SizedBox(height: 16),
            DateTimePickerRow(
              selectedDate: selectedDate,
              selectedTime: selectedTime,
              onDateChanged: updateDate,
              onTimeChanged: updateTime,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
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
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
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
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                    _calculatedBmi?.toStringAsFixed(2) ?? '—',
                    style: context.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _calculatedBmi != null
                          ? AppColors.primary
                          : AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
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
      ),
    );
  }
}
