import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/data/models/patient_advanced_filters.dart';
import 'package:frontend/patients/data/models/patient_list_params.dart';

/// Result returned from the advanced filter bottom sheet.
class PatientFilterResult {
  const PatientFilterResult({
    required this.filter,
    required this.advancedFilters,
  });

  final PatientFilter filter;
  final PatientAdvancedFilters? advancedFilters;
}

/// Advanced filter bottom sheet with status, gender, and health data filters.
class PatientFilterModal extends StatefulWidget {
  const PatientFilterModal({
    required this.currentFilter,
    required this.currentAdvancedFilters,
    super.key,
  });

  final PatientFilter currentFilter;
  final PatientAdvancedFilters? currentAdvancedFilters;

  @override
  State<PatientFilterModal> createState() => _PatientFilterModalState();
}

class _PatientFilterModalState extends State<PatientFilterModal> {
  late PatientFilter _filter;
  late String? _gender;

  late TextEditingController _bmiMinCtrl;
  late TextEditingController _bmiMaxCtrl;
  late TextEditingController _systolicMinCtrl;
  late TextEditingController _systolicMaxCtrl;
  late TextEditingController _diastolicMinCtrl;
  late TextEditingController _diastolicMaxCtrl;
  late TextEditingController _sugarMinCtrl;
  late TextEditingController _sugarMaxCtrl;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    final adv = widget.currentAdvancedFilters;
    _gender = adv?.gender;
    _bmiMinCtrl = TextEditingController(text: adv?.bmiMin?.toString() ?? '');
    _bmiMaxCtrl = TextEditingController(text: adv?.bmiMax?.toString() ?? '');
    _systolicMinCtrl =
        TextEditingController(text: adv?.systolicMin?.toString() ?? '');
    _systolicMaxCtrl =
        TextEditingController(text: adv?.systolicMax?.toString() ?? '');
    _diastolicMinCtrl =
        TextEditingController(text: adv?.diastolicMin?.toString() ?? '');
    _diastolicMaxCtrl =
        TextEditingController(text: adv?.diastolicMax?.toString() ?? '');
    _sugarMinCtrl = TextEditingController(
      text: adv?.sugarMin?.toString() ?? '',
    );
    _sugarMaxCtrl = TextEditingController(
      text: adv?.sugarMax?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _bmiMinCtrl.dispose();
    _bmiMaxCtrl.dispose();
    _systolicMinCtrl.dispose();
    _systolicMaxCtrl.dispose();
    _diastolicMinCtrl.dispose();
    _diastolicMaxCtrl.dispose();
    _sugarMinCtrl.dispose();
    _sugarMaxCtrl.dispose();
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      _filter = PatientFilter.all;
      _gender = null;
      _bmiMinCtrl.clear();
      _bmiMaxCtrl.clear();
      _systolicMinCtrl.clear();
      _systolicMaxCtrl.clear();
      _diastolicMinCtrl.clear();
      _diastolicMaxCtrl.clear();
      _sugarMinCtrl.clear();
      _sugarMaxCtrl.clear();
    });
  }

  void _apply() {
    final bmiMin = double.tryParse(_bmiMinCtrl.text);
    final bmiMax = double.tryParse(_bmiMaxCtrl.text);
    final systolicMin = int.tryParse(_systolicMinCtrl.text);
    final systolicMax = int.tryParse(_systolicMaxCtrl.text);
    final diastolicMin = int.tryParse(_diastolicMinCtrl.text);
    final diastolicMax = int.tryParse(_diastolicMaxCtrl.text);
    final sugarMin = double.tryParse(_sugarMinCtrl.text);
    final sugarMax = double.tryParse(_sugarMaxCtrl.text);

    final hasAdvanced = _gender != null ||
        bmiMin != null ||
        bmiMax != null ||
        systolicMin != null ||
        systolicMax != null ||
        diastolicMin != null ||
        diastolicMax != null ||
        sugarMin != null ||
        sugarMax != null;

    Navigator.pop(
      context,
      PatientFilterResult(
        filter: _filter,
        advancedFilters: hasAdvanced
            ? PatientAdvancedFilters(
                gender: _gender,
                bmiMin: bmiMin,
                bmiMax: bmiMax,
                systolicMin: systolicMin,
                systolicMax: systolicMax,
                diastolicMin: diastolicMin,
                diastolicMax: diastolicMax,
                sugarMin: sugarMin,
                sugarMax: sugarMax,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.filterTitle,
                    style: context.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    tooltip: l10n.cancelButton,
                  ),
                ],
              ),
            ),
            const Divider(),
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Status section
                    _SectionHeader(title: l10n.filterStatus),
                    const SizedBox(height: 8),
                    _StatusRadioGroup(
                      filter: _filter,
                      onChanged: (f) => setState(() => _filter = f),
                    ),
                    const SizedBox(height: 20),
                    // Gender section
                    _SectionHeader(title: l10n.filterGender),
                    const SizedBox(height: 8),
                    _GenderChips(
                      selected: _gender,
                      onChanged: (g) => setState(() => _gender = g),
                      maleLabel: l10n.genderMale,
                      femaleLabel: l10n.genderFemale,
                    ),
                    const SizedBox(height: 20),
                    // BMI range
                    _SectionHeader(title: l10n.filterBmiRange),
                    const SizedBox(height: 8),
                    _RangeFields(
                      minCtrl: _bmiMinCtrl,
                      maxCtrl: _bmiMaxCtrl,
                      fromLabel: l10n.filterFrom,
                      toLabel: l10n.filterTo,
                      allowDecimal: true,
                    ),
                    const SizedBox(height: 20),
                    // Blood pressure
                    _SectionHeader(title: l10n.filterBloodPressure),
                    const SizedBox(height: 8),
                    Text(
                      l10n.filterSystolic,
                      style: context.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _RangeFields(
                      minCtrl: _systolicMinCtrl,
                      maxCtrl: _systolicMaxCtrl,
                      fromLabel: l10n.filterFrom,
                      toLabel: l10n.filterTo,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.filterDiastolic,
                      style: context.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _RangeFields(
                      minCtrl: _diastolicMinCtrl,
                      maxCtrl: _diastolicMaxCtrl,
                      fromLabel: l10n.filterFrom,
                      toLabel: l10n.filterTo,
                    ),
                    const SizedBox(height: 20),
                    // Blood sugar
                    _SectionHeader(title: l10n.filterBloodSugar),
                    const SizedBox(height: 8),
                    _RangeFields(
                      minCtrl: _sugarMinCtrl,
                      maxCtrl: _sugarMaxCtrl,
                      fromLabel: l10n.filterFrom,
                      toLabel: l10n.filterTo,
                      allowDecimal: true,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Bottom actions
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearAll,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondaryText,
                        side: BorderSide(
                          color: AppColors.secondaryText.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(l10n.clearAllFilters),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(l10n.applyFilters),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _StatusRadioGroup extends StatelessWidget {
  const _StatusRadioGroup({
    required this.filter,
    required this.onChanged,
  });

  final PatientFilter filter;
  final ValueChanged<PatientFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: Text(l10n.filterAll),
          selected: filter == PatientFilter.all,
          onSelected: (_) => onChanged(PatientFilter.all),
          selectedColor: AppColors.secondary.withValues(alpha: 0.15),
          labelStyle: TextStyle(
            color: filter == PatientFilter.all
                ? AppColors.secondary
                : AppColors.mainText,
          ),
        ),
        ChoiceChip(
          label: Text(l10n.filterActive),
          selected: filter == PatientFilter.active,
          onSelected: (_) => onChanged(PatientFilter.active),
          selectedColor: AppColors.secondary.withValues(alpha: 0.15),
          labelStyle: TextStyle(
            color: filter == PatientFilter.active
                ? AppColors.secondary
                : AppColors.mainText,
          ),
        ),
        ChoiceChip(
          label: Text(l10n.filterInactive),
          selected: filter == PatientFilter.inactive,
          onSelected: (_) => onChanged(PatientFilter.inactive),
          selectedColor: AppColors.secondary.withValues(alpha: 0.15),
          labelStyle: TextStyle(
            color: filter == PatientFilter.inactive
                ? AppColors.secondary
                : AppColors.mainText,
          ),
        ),
      ],
    );
  }
}

class _GenderChips extends StatelessWidget {
  const _GenderChips({
    required this.selected,
    required this.onChanged,
    required this.maleLabel,
    required this.femaleLabel,
  });

  final String? selected;
  final ValueChanged<String?> onChanged;
  final String maleLabel;
  final String femaleLabel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: Text(maleLabel),
          selected: selected == 'male',
          onSelected: (_) =>
              onChanged(selected == 'male' ? null : 'male'),
          selectedColor: AppColors.secondary.withValues(alpha: 0.15),
          labelStyle: TextStyle(
            color: selected == 'male'
                ? AppColors.secondary
                : AppColors.mainText,
          ),
        ),
        ChoiceChip(
          label: Text(femaleLabel),
          selected: selected == 'female',
          onSelected: (_) =>
              onChanged(selected == 'female' ? null : 'female'),
          selectedColor: AppColors.secondary.withValues(alpha: 0.15),
          labelStyle: TextStyle(
            color: selected == 'female'
                ? AppColors.secondary
                : AppColors.mainText,
          ),
        ),
      ],
    );
  }
}

class _RangeFields extends StatelessWidget {
  const _RangeFields({
    required this.minCtrl,
    required this.maxCtrl,
    required this.fromLabel,
    required this.toLabel,
    this.allowDecimal = false,
  });

  final TextEditingController minCtrl;
  final TextEditingController maxCtrl;
  final String fromLabel;
  final String toLabel;
  final bool allowDecimal;

  @override
  Widget build(BuildContext context) {
    final inputFormatters = allowDecimal
        ? <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ]
        : <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly];

    final keyboardType = allowDecimal
        ? const TextInputType.numberWithOptions(decimal: true)
        : TextInputType.number;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: minCtrl,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: fromLabel,
              filled: true,
              fillColor: AppColors.inputFill,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide.none,
              ),
            ),
            style: context.bodyMedium,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('–'),
        ),
        Expanded(
          child: TextField(
            controller: maxCtrl,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: toLabel,
              filled: true,
              fillColor: AppColors.inputFill,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide.none,
              ),
            ),
            style: context.bodyMedium,
          ),
        ),
      ],
    );
  }
}

/// Shows the advanced patient filter bottom sheet.
/// Returns [PatientFilterResult], or null if dismissed.
Future<PatientFilterResult?> showPatientFilterModal({
  required BuildContext context,
  required PatientFilter currentFilter,
  PatientAdvancedFilters? currentAdvancedFilters,
}) {
  return showModalBottomSheet<PatientFilterResult>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.85,
    ),
    builder: (context) => PatientFilterModal(
      currentFilter: currentFilter,
      currentAdvancedFilters: currentAdvancedFilters,
    ),
  );
}
