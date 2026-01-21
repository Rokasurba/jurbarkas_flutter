import 'package:flutter/material.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';

/// Header widget with search field and filter button for patient list.
class PatientSearchHeader extends StatefulWidget {
  const PatientSearchHeader({
    required this.onSearchChanged,
    required this.onFilterTap,
    this.initialSearch,
    this.hasActiveFilter = false,
    super.key,
  });

  /// Callback when search text changes.
  final void Function(String query) onSearchChanged;

  /// Callback when filter button is tapped.
  final VoidCallback onFilterTap;

  /// Initial search text to display.
  final String? initialSearch;

  /// Whether a filter other than 'all' is active.
  final bool hasActiveFilter;

  @override
  State<PatientSearchHeader> createState() => _PatientSearchHeaderState();
}

class _PatientSearchHeaderState extends State<PatientSearchHeader> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialSearch);
  }

  @override
  void didUpdateWidget(PatientSearchHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller if external search changed (e.g., cleared from outside)
    if (widget.initialSearch != oldWidget.initialSearch &&
        widget.initialSearch != _controller.text) {
      _controller.text = widget.initialSearch ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    widget.onSearchChanged(value);
    setState(() {}); // Rebuild to show/hide clear button
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearchChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasText = _controller.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: l10n.searchPatientsHint,
                hintStyle: context.bodyMedium?.copyWith(
                  color: AppColors.secondaryText.withValues(alpha: 0.6),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.secondaryText,
                ),
                suffixIcon: hasText
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        color: AppColors.secondaryText,
                        onPressed: _clearSearch,
                        tooltip: l10n.cancelButton,
                      )
                    : null,
                filled: true,
                fillColor: AppColors.inputFill,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.secondary,
                    width: 2,
                  ),
                ),
              ),
              style: context.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 48,
            height: 48,
            child: Material(
              color: widget.hasActiveFilter
                  ? AppColors.secondary.withValues(alpha: 0.15)
                  : AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: widget.onFilterTap,
                borderRadius: BorderRadius.circular(12),
                child: Icon(
                  Icons.filter_list,
                  color: widget.hasActiveFilter
                      ? AppColors.secondary
                      : AppColors.secondaryText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
