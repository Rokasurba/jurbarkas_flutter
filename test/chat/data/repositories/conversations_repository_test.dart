import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/chat/data/repositories/conversations_repository.dart';
import 'package:frontend/core/core.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late ConversationsRepository repository;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = ConversationsRepository(apiClient: mockApiClient);
  });

  group('ConversationsRepository', () {
    group('getConversations', () {
      test('calls GET /conversations and parses list', () async {
        when(() => mockApiClient.get<Map<String, dynamic>>(
              any(),
            )).thenAnswer(
          (_) async => Response(
            data: {
              'success': true,
              'data': <Map<String, dynamic>>[
                {
                  'id': 1,
                  'other_user': {
                    'id': 2,
                    'name': 'Jonas',
                    'surname': 'Jonaitis',
                    'role': 'doctor',
                  },
                  'unread_count': 3,
                  'my_last_read_id': 5,
                  'updated_at': '2026-01-20T10:00:00.000Z',
                  'last_message': {
                    'id': 10,
                    'conversation_id': 1,
                    'sender_id': 2,
                    'content': 'Hello',
                    'created_at': '2026-01-20T10:00:00.000Z',
                  },
                },
              ],
              'message': 'OK',
            },
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        final result = await repository.getConversations();

        verify(() => mockApiClient.get<Map<String, dynamic>>(
              '/conversations',
            )).called(1);

        result.when(
          success: (data, _) {
            expect(data.length, 1);
            expect(data.first.id, 1);
            expect(data.first.otherUser.name, 'Jonas');
            expect(data.first.unreadCount, 3);
            expect(data.first.lastMessage, isNotNull);
            expect(data.first.lastMessage!.content, 'Hello');
          },
          error: (_, __) => fail('Expected success'),
        );
      });

      test('returns empty list when no conversations', () async {
        when(() => mockApiClient.get<Map<String, dynamic>>(
              any(),
            )).thenAnswer(
          (_) async => Response(
            data: {
              'success': true,
              'data': <Map<String, dynamic>>[],
              'message': 'OK',
            },
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        final result = await repository.getConversations();

        result.when(
          success: (data, _) {
            expect(data, isEmpty);
          },
          error: (_, __) => fail('Expected success'),
        );
      });

      test('returns error on DioException', () async {
        when(() => mockApiClient.get<Map<String, dynamic>>(
              any(),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(),
          message: 'Timeout',
        ));

        final result = await repository.getConversations();

        result.when(
          success: (_, __) => fail('Expected error'),
          error: (message, _) {
            expect(message, isNotEmpty);
          },
        );
      });
    });

    group('createConversation', () {
      test('calls POST /conversations with user_id', () async {
        when(() => mockApiClient.post<Map<String, dynamic>>(
              any(),
              data: any(named: 'data'),
            )).thenAnswer(
          (_) async => Response(
            data: {
              'success': true,
              'data': {
                'id': 5,
                'other_user': {
                  'id': 10,
                  'name': 'Petras',
                  'surname': 'Petraitis',
                  'role': 'patient',
                },
                'unread_count': 0,
                'my_last_read_id': 0,
                'updated_at': '2026-01-21T14:00:00.000Z',
              },
              'message': 'OK',
            },
            statusCode: 201,
            requestOptions: RequestOptions(),
          ),
        );

        final result = await repository.createConversation(10);

        verify(() => mockApiClient.post<Map<String, dynamic>>(
              '/conversations',
              data: {'user_id': 10},
            )).called(1);

        result.when(
          success: (data, _) {
            expect(data.id, 5);
            expect(data.otherUser.name, 'Petras');
            expect(data.unreadCount, 0);
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

        final result = await repository.createConversation(10);

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
