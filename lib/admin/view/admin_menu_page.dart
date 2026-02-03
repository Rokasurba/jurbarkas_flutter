import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';

@RoutePage()
class AdminMenuPage extends StatelessWidget {
  const AdminMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.administravimoMeniu),
      ),
      body: ListView(
        children: [
          _AdminMenuTile(
            icon: Icons.medical_services_outlined,
            title: l10n.gydytojai,
            subtitle: l10n.gydytojuValdymas,
            onTap: () {
              context.router.push(const DoctorListRoute());
            },
          ),
          _AdminMenuTile(
            icon: Icons.people_outline,
            title: l10n.pacientai,
            subtitle: l10n.pacientuValdymas,
            onTap: () {
              context.router.push(const PatientsRoute());
            },
          ),
          _AdminMenuTile(
            icon: Icons.history,
            title: l10n.veiklosZurnalas,
            subtitle: l10n.gdprVeiklosIrasai,
            onTap: () {
              context.router.push(const ActivityLogListRoute());
            },
          ),
        ],
      ),
    );
  }
}

class _AdminMenuTile extends StatelessWidget {
  const _AdminMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 32),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
