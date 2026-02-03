import 'package:flutter/material.dart';
import 'package:frontend/admin/cubit/activity_log_state.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:intl/intl.dart';

/// Bottom sheet for filtering activity logs.
class ActivityLogFilterBottomSheet extends StatefulWidget {
  const ActivityLogFilterBottomSheet({
    required this.currentFilters,
    super.key,
  });

  final ActivityLogFilters currentFilters;

  @override
  State<ActivityLogFilterBottomSheet> createState() =>
      _ActivityLogFilterBottomSheetState();
}

class _ActivityLogFilterBottomSheetState
    extends State<ActivityLogFilterBottomSheet> {
  late DateTime? _dateFrom;
  late DateTime? _dateTo;
  late String? _selectedEvent;

  final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _dateFrom = widget.currentFilters.dateFrom != null
        ? DateTime.tryParse(widget.currentFilters.dateFrom!)
        : null;
    _dateTo = widget.currentFilters.dateTo != null
        ? DateTime.tryParse(widget.currentFilters.dateTo!)
        : null;
    _selectedEvent = widget.currentFilters.event;
  }

  Future<void> _pickDateFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateFrom = picked);
    }
  }

  Future<void> _pickDateTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateTo = picked);
    }
  }

  void _applyFilters() {
    final filters = ActivityLogFilters(
      dateFrom: _dateFrom != null ? _dateFormat.format(_dateFrom!) : null,
      dateTo: _dateTo != null ? _dateFormat.format(_dateTo!) : null,
      event: _selectedEvent,
    );
    Navigator.of(context).pop(filters);
  }

  void _clearFilters() {
    Navigator.of(context).pop(const ActivityLogFilters());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      l10n.veiklosZurnaloFiltrai,
                      style: theme.textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date range section
                Text(
                  l10n.filtruotiPagalData,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _DateField(
                        label: l10n.nuo,
                        value: _dateFrom,
                        onTap: _pickDateFrom,
                        onClear: () => setState(() => _dateFrom = null),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _DateField(
                        label: l10n.iki,
                        value: _dateTo,
                        onTap: _pickDateTo,
                        onClear: () => setState(() => _dateTo = null),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Event type section
                Text(
                  l10n.filtruotiPagalVeiksma,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  initialValue: _selectedEvent,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    hintText: l10n.visiVeiksmai,
                  ),
                  items: [
                    DropdownMenuItem(
                      child: Text(l10n.visiVeiksmai),
                    ),
                    DropdownMenuItem(
                      value: 'created',
                      child: Text(l10n.sukurta),
                    ),
                    DropdownMenuItem(
                      value: 'updated',
                      child: Text(l10n.atnaujinta),
                    ),
                    DropdownMenuItem(
                      value: 'deleted',
                      child: Text(l10n.istrinta),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedEvent = value);
                  },
                ),
                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clearFilters,
                        child: Text(l10n.isvalyti),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: _applyFilters,
                        child: Text(l10n.taikyti),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: value != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: onClear,
                )
              : const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          value != null ? dateFormat.format(value!) : '-',
        ),
      ),
    );
  }
}
