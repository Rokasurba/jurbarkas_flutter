import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/patients/widgets/status_badge.dart';

import '../../helpers/helpers.dart';

void main() {
  group('StatusBadge', () {
    testWidgets('displays active status with correct text', (tester) async {
      await tester.pumpApp(
        const StatusBadge(isActive: true),
      );

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('displays inactive status with correct text', (tester) async {
      await tester.pumpApp(
        const StatusBadge(isActive: false),
      );

      expect(find.text('Inactive'), findsOneWidget);
    });

    testWidgets('has semantic label for accessibility', (tester) async {
      await tester.pumpApp(
        const StatusBadge(isActive: true),
      );

      final semantics = tester.getSemantics(find.byType(StatusBadge));
      expect(semantics.label, contains('Active'));
    });

    testWidgets('inactive badge has semantic label', (tester) async {
      await tester.pumpApp(
        const StatusBadge(isActive: false),
      );

      final semantics = tester.getSemantics(find.byType(StatusBadge));
      expect(semantics.label, contains('Inactive'));
    });
  });
}
