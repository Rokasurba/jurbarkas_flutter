import 'package:flutter/material.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/data/models/patient_list_params.dart';

/// Modal bottom sheet for selecting patient filter.
class PatientFilterModal extends StatelessWidget {
  const PatientFilterModal({
    required this.currentFilter,
    required this.onFilterSelected,
    super.key,
  });

  /// Currently selected filter.
  final PatientFilter currentFilter;

  /// Callback when a filter is selected.
  final void Function(PatientFilter filter) onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
            const SizedBox(height: 8),
            const Divider(),
            // Filter options
            _FilterOption(
              label: l10n.filterAll,
              isSelected: currentFilter == PatientFilter.all,
              onTap: () => onFilterSelected(PatientFilter.all),
            ),
            _FilterOption(
              label: l10n.filterActive,
              isSelected: currentFilter == PatientFilter.active,
              onTap: () => onFilterSelected(PatientFilter.active),
            ),
            _FilterOption(
              label: l10n.filterInactive,
              isSelected: currentFilter == PatientFilter.inactive,
              onTap: () => onFilterSelected(PatientFilter.inactive),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  const _FilterOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: context.bodyLarge?.copyWith(
                  color: isSelected ? AppColors.secondary : AppColors.mainText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                color: AppColors.secondary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

/// Shows the patient filter modal as a bottom sheet.
/// Returns the selected filter, or null if dismissed.
Future<PatientFilter?> showPatientFilterModal({
  required BuildContext context,
  required PatientFilter currentFilter,
}) {
  return showModalBottomSheet<PatientFilter>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => PatientFilterModal(
      currentFilter: currentFilter,
      onFilterSelected: (filter) {
        Navigator.pop(context, filter);
      },
    ),
  );
}
