import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/chat/data/repositories/chat_repository.dart';
import 'package:frontend/core/core.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late ChatRepository repository;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = ChatRepository(apiClient: mockApiClient);
  });

  group('ChatRepository', () {
    group('getMessages', () {
      test('calls GET with correct path and no query params by default',
          () async {
        when(() => mockApiClient.get<Map<String, dynamic>>(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer(
          (_) async => Response(
            data: {
              'success': true,
              'data': {
                'messages': <Map<String, dynamic>>[],
                'my_last_read_id': 0,
                'has_more': false,
              },
              'message': 'OK',
            },
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        final result = await repository.getMessages(10);

        verify(() => mockApiClient.get<Map<String, dynamic>>(
              '/conversations/10/messages',
              queryParameters: any(named: 'queryParameters'),
            )).called(1);

        result.when(
          success: (data, _) {
            expect(data.messages, isEmpty);
            expect(data.myLastReadId, 0);
            expect(data.hasMore, isFalse);
          },
          error: (_, __) => fail('Expected success'),
        );
      });

      test('passes limit, afterId, beforeId as query params', () async {
        when(() => mockApiClient.get<Map<String, dynamic>>(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer(
          (_) async => Response(
            data: {
              'success': true,
              'data': {
                'messages': <Map<String, dynamic>>[],
                'my_last_read_id': 0,
                'has_more': false,
              },
              'message': 'OK',
            },
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        await repository.getMessages(
          10,
          limit: 20,
          afterId: 5,
          beforeId: 100,
        );

        final captured = verify(() => mockApiClient.get<Map<String, dynamic>>(
              '/conversations/10/messages',
              queryParameters: captureAny(named: 'queryParameters'),
            )).captured.single as Map<String, dynamic>?;

        expect(captured, isNotNull);
        expect(captured!['limit'], 20);
        expect(captured['after_id'], 5);
        expect(captured['before_id'], 100);
      });

      test('returns error on DioException', () async {
        when(() => mockApiClient.get<Map<String, dynamic>>(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(),
          message: 'Timeout',
        ));

        final result = await repository.getMessages(10);

        result.when(
          success: (_, __) => fail('Expected error'),
          error: (message, _) {
            expect(message, isNotEmpty);
          },
        );
      });
    });

    group('sendMessage', () {
      test('calls POST with correct path and body', () async {
        when(() => mockApiClient.post<Map<String, dynamic>>(
              any(),
              data: any(named: 'data'),
            )).thenAnswer(
          (_) async => Response(
            data: {
              'success': true,
              'data': {
                'id': 42,
                'conversation_id': 10,
                'sender_id': 1,
                'content': 'Hello',
                'created_at': '2026-01-20T10:00:00.000Z',
              },
              'message': 'OK',
            },
            statusCode: 201,
            requestOptions: RequestOptions(),
          ),
        );

        final result = await repository.sendMessage(10, 'Hello');

        verify(() => mockApiClient.post<Map<String, dynamic>>(
              '/conversations/10/messages',
              data: {'content': 'Hello'},
            )).called(1);

        result.when(
          success: (msg, _) {
            expect(msg.id, 42);
            expect(msg.content, 'Hello');
            expect(msg.senderId, 1);
          },
          error: (_, __) => fail('Expected success'),
        );
      });

      test('returns error on DioException', () async {
        when(() => mockApiClient.post<Map<String, dynamic>>(
              any(),
              data: any(named: 'data'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(),
        ));

        final result = await repository.sendMessage(10, 'Hello');

        result.when(
          success: (_, __) => fail('Expected error'),
          error: (message, _) {
            expect(message, isNotEmpty);
          },
        );
      });
    });

    group('markAsRead', () {
      test('calls PATCH with correct path and body', () async {
        when(() => mockApiClient.patch<Map<String, dynamic>>(
              any(),
              data: any(named: 'data'),
            )).thenAnswer(
          (_) async => Response(
            data: {
              'success': true,
              'data': null,
              'message': 'OK',
            },
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        final result = await repository.markAsRead(10, 5);

        verify(() => mockApiClient.patch<Map<String, dynamic>>(
              '/conversations/10/read',
              data: {'last_read_id': 5},
            )).called(1);

        result.when(
          success: (_, __) {},
          error: (_, __) => fail('Expected success'),
        );
      });

      test('returns error on DioException', () async {
        when(() => mockApiClient.patch<Map<String, dynamic>>(
              any(),
              data: any(named: 'data'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(),
        ));

        final result = await repository.markAsRead(10, 5);

        result.when(
          success: (_, __) => fail('Expected error'),
          error: (message, _) {
            expect(message, isNotEmpty);
          },
        );
      });
    });
  });
}
