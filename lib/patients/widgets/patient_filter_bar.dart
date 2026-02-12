import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/cubit/patients_cubit.dart';
import 'package:frontend/patients/data/models/patient_list_params.dart';

/// Horizontal scrollable bar with filter button and active filter chips.
class PatientFilterBar extends StatelessWidget {
  const PatientFilterBar({
    required this.params,
    required this.onFilterTap,
    super.key,
  });

  final PatientListParams params;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PatientsCubit>();
    final chips = <Widget>[];

    if (params.filter != PatientFilter.all) {
      final label = params.filter == PatientFilter.active
          ? l10n.filterActive
          : l10n.filterInactive;
      chips.add(
        _FilterChip(
          label: label,
          onRemove: () => unawaited(cubit.clearStatusFilter()),
        ),
      );
    }

    final adv = params.advancedFilters;
    if (adv != null) {
      if (adv.gender != null) {
        final genderLabel = adv.gender == 'male'
            ? l10n.genderMale
            : l10n.genderFemale;
        chips.add(
          _FilterChip(
            label: l10n.chipGender(genderLabel),
            onRemove: () =>
                unawaited(cubit.clearGenderFilter()),
          ),
        );
      }

      if (adv.bmiMin != null || adv.bmiMax != null) {
        chips.add(
          _FilterChip(
            label: l10n.chipBmi(
              _rangeText(adv.bmiMin, adv.bmiMax),
            ),
            onRemove: () =>
                unawaited(cubit.clearBmiFilter()),
          ),
        );
      }

      if (adv.systolicMin != null ||
          adv.systolicMax != null) {
        chips.add(
          _FilterChip(
            label: l10n.chipSystolic(
              _rangeText(
                adv.systolicMin,
                adv.systolicMax,
              ),
            ),
            onRemove: () =>
                unawaited(cubit.clearSystolicFilter()),
          ),
        );
      }

      if (adv.diastolicMin != null ||
          adv.diastolicMax != null) {
        chips.add(
          _FilterChip(
            label: l10n.chipDiastolic(
              _rangeText(
                adv.diastolicMin,
                adv.diastolicMax,
              ),
            ),
            onRemove: () =>
                unawaited(cubit.clearDiastolicFilter()),
          ),
        );
      }

      if (adv.sugarMin != null || adv.sugarMax != null) {
        chips.add(
          _FilterChip(
            label: l10n.chipSugar(
              _rangeText(adv.sugarMin, adv.sugarMax),
            ),
            onRemove: () =>
                unawaited(cubit.clearSugarFilter()),
          ),
        );
      }
    }

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FilterButton(
            onTap: onFilterTap,
            hasActiveFilters: params.hasActiveFilters,
          ),
          ...chips.map(
            (chip) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: chip,
            ),
          ),
        ],
      ),
    );
  }

  String _rangeText(num? min, num? max) {
    if (min != null && max != null) return '$min–$max';
    if (min != null) return '$min+';
    if (max != null) return '≤$max';
    return '';
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.onTap,
    required this.hasActiveFilters,
  });

  final VoidCallback onTap;
  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: hasActiveFilters
                  ? AppColors.secondary
                  : AppColors.secondary
                      .withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune,
                size: 18,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.filterBy,
                style: context.bodyMedium?.copyWith(
                  color: AppColors.mainText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onRemove,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.secondary),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.close,
                size: 22,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: context.bodyMedium?.copyWith(
                  color: AppColors.mainText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
