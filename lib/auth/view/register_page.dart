import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:frontend/l10n/l10n.dart';

@RoutePage()
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registerTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: Center(
        child: Text(
          l10n.registerComingSoon,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
