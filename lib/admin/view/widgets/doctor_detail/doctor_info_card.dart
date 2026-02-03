import 'package:flutter/material.dart';
import 'package:frontend/admin/view/widgets/doctor_detail/info_row.dart';
import 'package:frontend/admin/view/widgets/doctor_detail/status_badge.dart';
import 'package:frontend/auth/data/models/user_model.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:intl/intl.dart';

class DoctorInfoCard extends StatelessWidget {
  const DoctorInfoCard({required this.doctor, super.key});

  final User doctor;

  @override
  Widget build(BuildContext context) {
    debugPrint('[DoctorInfoCard] build() START');
    final l10n = context.l10n;
    debugPrint('[DoctorInfoCard] Got l10n');
    final dateFormat = DateFormat('yyyy-MM-dd');
    debugPrint('[DoctorInfoCard] Created DateFormat');

    debugPrint('[DoctorInfoCard] Building Card widget...');
    final card = Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DoctorHeader(doctor: doctor),
            const Divider(height: 32),
            InfoRow(
              icon: Icons.email_outlined,
              label: l10n.emailLabel,
              value: doctor.email,
            ),
            const SizedBox(height: 12),
            InfoRow(
              icon: Icons.phone_outlined,
              label: l10n.phone,
              value: doctor.phone ?? l10n.notSpecified,
            ),
            const SizedBox(height: 12),
            InfoRow(
              icon: Icons.calendar_today_outlined,
              label: l10n.registrationDate,
              value: doctor.createdAt != null
                  ? dateFormat.format(doctor.createdAt!)
                  : l10n.notSpecified,
            ),
          ],
        ),
      ),
    );
    debugPrint('[DoctorInfoCard] build() END');
    return card;
  }
}

class _DoctorHeader extends StatelessWidget {
  const _DoctorHeader({required this.doctor});

  final User doctor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: doctor.isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          child: Text(
            doctor.initials,
            style: theme.textTheme.titleLarge?.copyWith(
              color: doctor.isActive
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctor.fullName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              StatusBadge(isActive: doctor.isActive),
            ],
          ),
        ),
      ],
    );
  }
}
