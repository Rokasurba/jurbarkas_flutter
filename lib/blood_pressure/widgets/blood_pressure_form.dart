import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blood_pressure/cubit/blood_pressure_cubit.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';

class BloodPressureForm extends StatefulWidget {
  const BloodPressureForm({
    required this.onSubmit,
    required this.isLoading,
    super.key,
  });

  final void Function(int systolic, int diastolic, DateTime measuredAt) onSubmit;
  final bool isLoading;

  @override
  BloodPressureFormState createState() => BloodPressureFormState();
}

class BloodPressureFormState extends State<BloodPressureForm>
    with DateTimePickerMixin {
  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initDateTime();
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
      widget.onSubmit(systolic, diastolic, combinedDateTime);
    }
  }

  void _clearForm() {
    _systolicController.clear();
    _diastolicController.clear();
    resetDateTime();
    setState(() {});
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

    return BlocListener<BloodPressureCubit, BloodPressureState>(
      listenWhen: (previous, current) => current is BloodPressureSaved,
      listener: (context, state) => _clearForm(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.bloodPressureNewSection,
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
            // Blood pressure row
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
            AppButton.primary(
              label: l10n.saveButton,
              onPressed: _submit,
              isLoading: widget.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
