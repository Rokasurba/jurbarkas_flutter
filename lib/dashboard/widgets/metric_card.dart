import 'package:flutter/material.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:intl/intl.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.title,
    required this.onTap,
    this.value,
    this.unit,
    this.icon,
    this.measuredAt,
    super.key,
  });

  final String title;
  final String? value;
  final String? unit;
  final IconData? icon;
  final DateTime? measuredAt;
  final VoidCallback onTap;

  bool get _isEmpty => value == null || value!.isEmpty;

  String _formatTimestamp(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final measureDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final locale = Localizations.localeOf(context);

    if (measureDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (measureDate == yesterday) {
      return locale.languageCode == 'lt' ? 'Vakar' : 'Yesterday';
    } else {
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mainText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_isEmpty) ...[
                      Text(
                        l10n.noDataYet,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.addFirstReading,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ] else ...[
                      Text(
                        unit != null ? '$value $unit' : value!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (measuredAt != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          l10n.checkedAt(
                            _formatTimestamp(context, measuredAt!),
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
