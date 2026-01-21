import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/blood_pressure/widgets/blood_pressure_graph.dart';

void main() {
  group('GraphPeriod', () {
    group('toFromDate', () {
      test('week returns date 7 days ago', () {
        final now = DateTime.now();
        final result = GraphPeriod.week.toFromDate();

        expect(result, isNotNull);
        final difference = now.difference(result!).inDays;
        // Allow for slight timing differences
        expect(difference, inInclusiveRange(6, 7));
      });

      test('month returns date 30 days ago', () {
        final now = DateTime.now();
        final result = GraphPeriod.month.toFromDate();

        expect(result, isNotNull);
        final difference = now.difference(result!).inDays;
        expect(difference, inInclusiveRange(29, 30));
      });

      test('threeMonths returns date 90 days ago', () {
        final now = DateTime.now();
        final result = GraphPeriod.threeMonths.toFromDate();

        expect(result, isNotNull);
        final difference = now.difference(result!).inDays;
        expect(difference, inInclusiveRange(89, 90));
      });

      test('allTime returns null', () {
        final result = GraphPeriod.allTime.toFromDate();
        expect(result, isNull);
      });
    });

    test('enum has correct values', () {
      expect(GraphPeriod.values, hasLength(4));
      expect(GraphPeriod.values, contains(GraphPeriod.week));
      expect(GraphPeriod.values, contains(GraphPeriod.month));
      expect(GraphPeriod.values, contains(GraphPeriod.threeMonths));
      expect(GraphPeriod.values, contains(GraphPeriod.allTime));
    });
  });
}
