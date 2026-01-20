import 'package:flutter/material.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:intl/intl.dart';

/// A row with date and time picker fields.
///
/// Usage:
/// ```dart
/// DateTimePickerRow(
///   selectedDate: _selectedDate,
///   selectedTime: _selectedTime,
///   onDateChanged: (date) => setState(() => _selectedDate = date),
///   onTimeChanged: (time) => setState(() => _selectedTime = time),
/// )
/// ```
class DateTimePickerRow extends StatelessWidget {
  const DateTimePickerRow({
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateChanged,
    required this.onTimeChanged,
    this.firstDate,
    this.lastDate,
    super.key,
  });

  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  /// First selectable date. Defaults to 1 year ago.
  final DateTime? firstDate;

  /// Last selectable date. Defaults to today.
  final DateTime? lastDate;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate ?? now.subtract(const Duration(days: 365)),
      lastDate: lastDate ?? now,
    );
    if (picked != null) {
      onDateChanged(picked);
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      onTimeChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');

    return Row(
      children: [
        Expanded(
          child: _PickerField(
            label: l10n.dateLabel,
            value: dateFormat.format(selectedDate),
            icon: Icons.calendar_today,
            onTap: () => _pickDate(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PickerField(
            label: l10n.timeLabel,
            value: timeFormat.format(
              DateTime(0, 0, 0, selectedTime.hour, selectedTime.minute),
            ),
            icon: Icons.access_time,
            onTap: () => _pickTime(context),
          ),
        ),
      ],
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(icon, size: 20),
        ),
        child: Text(value),
      ),
    );
  }
}

/// Helper mixin for forms that need date/time selection.
///
/// Usage:
/// ```dart
/// class _MyFormState extends State<MyForm> with DateTimePickerMixin {
///   @override
///   void initState() {
///     super.initState();
///     initDateTime(); // Call this in initState
///   }
///
///   DateTime get measuredAt => combinedDateTime;
///
///   void clearForm() {
///     resetDateTime();
///     setState(() {});
///   }
/// }
/// ```
mixin DateTimePickerMixin<T extends StatefulWidget> on State<T> {
  late DateTime selectedDate;
  late TimeOfDay selectedTime;

  /// Initialize date/time to current moment. Call in initState.
  void initDateTime() {
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    selectedTime = TimeOfDay(hour: now.hour, minute: now.minute);
  }

  /// Reset date/time to current moment.
  void resetDateTime() {
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    selectedTime = TimeOfDay(hour: now.hour, minute: now.minute);
  }

  /// Get combined DateTime from selected date and time.
  DateTime get combinedDateTime => DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

  /// Update selected date and rebuild.
  void updateDate(DateTime date) {
    setState(() => selectedDate = date);
  }

  /// Update selected time and rebuild.
  void updateTime(TimeOfDay time) {
    setState(() => selectedTime = time);
  }
}
