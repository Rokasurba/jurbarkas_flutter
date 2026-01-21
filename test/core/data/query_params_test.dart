import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/data/query_params.dart';

void main() {
  group('HealthDataParams', () {
    test('firstPage creates params with default limit and no filter', () {
      const params = HealthDataParams.firstPage();

      expect(params.limit, HealthDataParams.defaultPageSize);
      expect(params.offset, isNull);
      expect(params.from, isNull);
      expect(params.hasDateFilter, isFalse);
      expect(params.isLoadingMore, isFalse);
    });

    test('nextPage creates params with offset for pagination', () {
      final params = HealthDataParams.nextPage(20);

      expect(params.limit, HealthDataParams.defaultPageSize);
      expect(params.offset, 20);
      expect(params.from, isNull);
      expect(params.isLoadingMore, isTrue);
    });

    test('withDateFilter creates params with date filter and higher limit', () {
      final date = DateTime(2026, 1, 1);
      final params = HealthDataParams.withDateFilter(date);

      expect(params.limit, 500);
      expect(params.offset, isNull);
      expect(params.from, date);
      expect(params.hasDateFilter, isTrue);
      expect(params.isLoadingMore, isFalse);
    });

    group('toQueryMap', () {
      test('firstPage generates correct query map', () {
        const params = HealthDataParams.firstPage();
        final map = params.toQueryMap();

        expect(map, {'limit': 20});
        expect(map.containsKey('offset'), isFalse);
        expect(map.containsKey('from'), isFalse);
      });

      test('nextPage generates correct query map with offset', () {
        final params = HealthDataParams.nextPage(40);
        final map = params.toQueryMap();

        expect(map, {'limit': 20, 'offset': 40});
        expect(map.containsKey('from'), isFalse);
      });

      test('withDateFilter generates correct query map with date', () {
        final date = DateTime(2026, 1, 15);
        final params = HealthDataParams.withDateFilter(date);
        final map = params.toQueryMap();

        expect(map, {'limit': 500, 'from': '2026-01-15'});
        expect(map.containsKey('offset'), isFalse);
      });

      test('date is formatted as ISO date only (no time)', () {
        final dateWithTime = DateTime(2026, 1, 15, 14, 30, 45);
        final params = HealthDataParams.withDateFilter(dateWithTime);
        final map = params.toQueryMap();

        // Should only include date part, not time
        expect(map['from'], '2026-01-15');
      });

      test('offset of 0 is excluded from query map', () {
        const params = HealthDataParams(limit: 20, offset: 0);
        final map = params.toQueryMap();

        expect(map, {'limit': 20});
        expect(map.containsKey('offset'), isFalse);
      });
    });

    test('toQueryMapOrNull returns null for empty params', () {
      const params = HealthDataParams();
      expect(params.toQueryMapOrNull(), isNull);
    });

    test('toQueryMapOrNull returns map when not empty', () {
      const params = HealthDataParams.firstPage();
      expect(params.toQueryMapOrNull(), isNotNull);
    });
  });

  group('PaginationParams', () {
    test('firstPage creates params with default limit', () {
      const params = PaginationParams.firstPage();

      expect(params.limit, PaginationParams.defaultPageSize);
      expect(params.offset, isNull);
      expect(params.isLoadingMore, isFalse);
    });

    test('nextPage creates params for loading more', () {
      final params = PaginationParams.nextPage(20);

      expect(params.limit, PaginationParams.defaultPageSize);
      expect(params.offset, 20);
      expect(params.isLoadingMore, isTrue);
    });

    test('toQueryMap excludes null values', () {
      const params = PaginationParams();
      final map = params.toQueryMap();

      expect(map, isEmpty);
    });

    test('toQueryMap includes non-null values', () {
      const params = PaginationParams(limit: 10, offset: 5);
      final map = params.toQueryMap();

      expect(map, {'limit': 10, 'offset': 5});
    });
  });
}
