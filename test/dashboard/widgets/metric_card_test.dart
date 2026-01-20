import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/dashboard/widgets/metric_card.dart';

import '../../helpers/helpers.dart';

void main() {
  group('MetricCard', () {
    testWidgets('displays title', (tester) async {
      await tester.pumpApp(
        MetricCard(
          title: 'Blood Pressure',
          value: '120/80',
          unit: 'mmHg',
          onTap: () {},
        ),
      );

      expect(find.text('Blood Pressure'), findsOneWidget);
    });

    testWidgets('displays value with unit when data exists', (tester) async {
      await tester.pumpApp(
        MetricCard(
          title: 'Blood Pressure',
          value: '120/80',
          unit: 'mmHg',
          onTap: () {},
        ),
      );

      expect(find.text('120/80 mmHg'), findsOneWidget);
    });

    testWidgets('displays value without unit when unit is null', (
      tester,
    ) async {
      await tester.pumpApp(
        MetricCard(
          title: 'BMI',
          value: '23.5',
          onTap: () {},
        ),
      );

      expect(find.text('23.5'), findsOneWidget);
    });

    testWidgets('displays empty state when value is null', (tester) async {
      await tester.pumpApp(
        MetricCard(
          title: 'Blood Pressure',
          onTap: () {},
        ),
      );

      // Should show "No data yet" (or Lithuanian translation)
      expect(find.textContaining('No data'), findsOneWidget);
      // Should show "Add your first reading" prompt
      expect(find.textContaining('Add your first'), findsOneWidget);
    });

    testWidgets('displays empty state when value is empty string', (
      tester,
    ) async {
      await tester.pumpApp(
        MetricCard(
          title: 'Blood Pressure',
          value: '',
          onTap: () {},
        ),
      );

      expect(find.textContaining('No data'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpApp(
        MetricCard(
          title: 'Blood Pressure',
          value: '120/80',
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byType(MetricCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('displays chevron right icon', (tester) async {
      await tester.pumpApp(
        MetricCard(
          title: 'Blood Pressure',
          value: '120/80',
          onTap: () {},
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('has InkWell for tap feedback', (tester) async {
      await tester.pumpApp(
        MetricCard(
          title: 'Blood Pressure',
          value: '120/80',
          onTap: () {},
        ),
      );

      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('displays metric icon when provided', (tester) async {
      await tester.pumpApp(
        MetricCard(
          title: 'Blood Pressure',
          value: '120/80',
          icon: Icons.favorite,
          onTap: () {},
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('does not display icon container when icon is null', (
      tester,
    ) async {
      await tester.pumpApp(
        MetricCard(
          title: 'Blood Pressure',
          value: '120/80',
          onTap: () {},
        ),
      );

      // Only chevron_right icon should exist, not any metric icon
      final icons = tester.widgetList<Icon>(find.byType(Icon));
      expect(icons.length, 1);
      expect(icons.first.icon, Icons.chevron_right);
    });

    testWidgets('displays timestamp when measuredAt is provided', (
      tester,
    ) async {
      final today = DateTime.now();
      await tester.pumpApp(
        MetricCard(
          title: 'Blood Pressure',
          value: '120/80',
          measuredAt: today,
          onTap: () {},
        ),
      );

      // Should show "Checked:" text
      expect(find.textContaining('Checked:'), findsOneWidget);
    });

    testWidgets('does not display timestamp when measuredAt is null', (
      tester,
    ) async {
      await tester.pumpApp(
        MetricCard(
          title: 'Blood Pressure',
          value: '120/80',
          onTap: () {},
        ),
      );

      expect(find.textContaining('Checked:'), findsNothing);
    });

    testWidgets('does not display timestamp in empty state', (tester) async {
      await tester.pumpApp(
        MetricCard(
          title: 'Blood Pressure',
          measuredAt: DateTime.now(),
          onTap: () {},
        ),
      );

      // When value is null, timestamp should not be displayed
      expect(find.textContaining('Checked:'), findsNothing);
    });
  });
}
