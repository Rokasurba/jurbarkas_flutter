import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blood_sugar/cubit/blood_sugar_cubit.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';

class BloodSugarForm extends StatefulWidget {
  const BloodSugarForm({
    required this.onSubmit,
    required this.isLoading,
    super.key,
  });

  final void Function(double glucoseLevel, DateTime measuredAt) onSubmit;
  final bool isLoading;

  @override
  BloodSugarFormState createState() => BloodSugarFormState();
}

class BloodSugarFormState extends State<BloodSugarForm>
    with DateTimePickerMixin {
  final _formKey = GlobalKey<FormState>();
  final _glucoseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initDateTime();
  }

  @override
  void dispose() {
    _glucoseController.dispose();
    super.dispose();
  }

  /// Clears the form. Call this from parent when save succeeds.
  void clearForm() {
    _glucoseController.clear();
    resetDateTime();
    setState(() {});
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final glucoseLevel = double.parse(
        _glucoseController.text.replaceAll(',', '.'),
      );
      widget.onSubmit(glucoseLevel, combinedDateTime);
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

    return BlocListener<BloodSugarCubit, BloodSugarState>(
      listenWhen: (previous, current) => current is BloodSugarSaved,
      listener: (context, state) => clearForm(),
      child: Form(
        key: _formKey,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.bloodSugarNewSection,
            style: context.sectionHeader,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _glucoseController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
          const SizedBox(height: 16),
          DateTimePickerRow(
            selectedDate: selectedDate,
            selectedTime: selectedTime,
            onDateChanged: updateDate,
            onTimeChanged: updateTime,
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
