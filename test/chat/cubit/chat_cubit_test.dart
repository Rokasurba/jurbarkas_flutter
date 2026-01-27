import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/chat/cubit/chat_cubit.dart';
import 'package:frontend/chat/data/models/chat_message.dart';
import 'package:frontend/chat/data/models/messages_response.dart';
import 'package:frontend/chat/data/models/user_brief.dart';
import 'package:frontend/chat/data/repositories/chat_repository.dart';
import 'package:frontend/core/data/api_response.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository mockRepository;

  const otherUser = UserBrief(
    id: 2,
    name: 'Jonas',
    surname: 'Jonaitis',
    role: 'doctor',
  );

  final mockMessages = [
    ChatMessage(
      id: 1,
      conversationId: 10,
      senderId: 2,
      content: 'Hello',
      createdAt: DateTime(2026, 1, 20, 10),
    ),
    ChatMessage(
      id: 2,
      conversationId: 10,
      senderId: 1,
      content: 'Hi there',
      createdAt: DateTime(2026, 1, 20, 10, 5),
    ),
  ];

  final mockMessagesResponse = MessagesResponse(
    messages: mockMessages,
    myLastReadId: 1,
    hasMore: false,
  );

  final mockMessagesResponseWithMore = MessagesResponse(
    messages: mockMessages,
    myLastReadId: 1,
    hasMore: true,
  );

  setUp(() {
    mockRepository = MockChatRepository();
  });

  ChatCubit buildCubit({int initialLastReadId = 0}) {
    return ChatCubit(
      conversationId: 10,
      currentUserId: 1,
      otherUser: otherUser,
      chatRepository: mockRepository,
      initialLastReadId: initialLastReadId,
    );
  }

  group('ChatCubit', () {
    test('initial state is ChatInitial', () {
      final cubit = buildCubit();
      expect(cubit.state, const ChatState.initial());
      cubit.close();
    });

    test('exposes otherUser, currentUserId, conversationId', () {
      final cubit = buildCubit();
      expect(cubit.otherUser, otherUser);
      expect(cubit.currentUserId, 1);
      expect(cubit.conversationId, 10);
      cubit.close();
    });

    group('loadMessages', () {
      blocTest<ChatCubit, ChatState>(
        'emits [loading, loaded] when getMessages succeeds',
        setUp: () {
          when(() => mockRepository.getMessages(
                10,
                limit: 20,
              )).thenAnswer(
            (_) async => ApiResponse.success(data: mockMessagesResponse),
          );
          when(() => mockRepository.markAsRead(10, any())).thenAnswer(
            (_) async => const ApiResponse.success(data: null),
          );
        },
        build: () => buildCubit(),
        act: (cubit) => cubit.loadMessages(),
        expect: () => [
          const ChatState.loading(),
          isA<ChatLoaded>()
              .having((s) => s.messages.length, 'messages count', 2)
              .having((s) => s.hasMore, 'hasMore', false)
              .having((s) => s.isLoadingMore, 'isLoadingMore', false)
              .having((s) => s.myLastReadId, 'myLastReadId', 1),
        ],
      );

      blocTest<ChatCubit, ChatState>(
        'emits [loading, error] when getMessages fails',
        setUp: () {
          when(() => mockRepository.getMessages(
                10,
                limit: 20,
              )).thenAnswer(
            (_) async =>
                const ApiResponse.error(message: 'Connection failed'),
          );
        },
        build: () => buildCubit(),
        act: (cubit) => cubit.loadMessages(),
        expect: () => [
          const ChatState.loading(),
          const ChatState.error('Connection failed'),
        ],
      );

      test('marks unread messages as read on load', () async {
        // API returns myLastReadId: 0, meaning messages from other user
        // with id > 0 are unread
        final unreadResponse = MessagesResponse(
          messages: mockMessages,
          myLastReadId: 0,
          hasMore: false,
        );
        when(() => mockRepository.getMessages(
              any(),
              limit: any(named: 'limit'),
              afterId: any(named: 'afterId'),
              beforeId: any(named: 'beforeId'),
            )).thenAnswer(
          (_) async => ApiResponse.success(data: unreadResponse),
        );
        when(() => mockRepository.markAsRead(any(), any())).thenAnswer(
          (_) async => const ApiResponse.success(data: null),
        );

        final cubit = buildCubit(initialLastReadId: 0);
        await cubit.loadMessages();
        // Wait for the unawaited markAsRead to complete
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        verify(() => mockRepository.markAsRead(10, 1)).called(1);
        await cubit.close();
      });

      blocTest<ChatCubit, ChatState>(
        'does not mark as read when all messages already read',
        setUp: () {
          when(() => mockRepository.getMessages(
                10,
                limit: 20,
              )).thenAnswer(
            (_) async => ApiResponse.success(data: mockMessagesResponse),
          );
        },
        build: () => buildCubit(initialLastReadId: 2),
        act: (cubit) => cubit.loadMessages(),
        verify: (_) {
          verifyNever(() => mockRepository.markAsRead(any(), any()));
        },
      );
    });

    group('loadMoreMessages', () {
      blocTest<ChatCubit, ChatState>(
        'loads older messages with beforeId',
        setUp: () {
          when(() => mockRepository.getMessages(
                10,
                limit: 20,
              )).thenAnswer(
            (_) async =>
                ApiResponse.success(data: mockMessagesResponseWithMore),
          );
          final olderMessages = [
            ChatMessage(
              id: 0,
              conversationId: 10,
              senderId: 2,
              content: 'Older message',
              createdAt: DateTime(2026, 1, 19),
            ),
          ];
          when(() => mockRepository.getMessages(
                10,
                limit: 20,
                beforeId: 1,
              )).thenAnswer(
            (_) async => ApiResponse.success(
              data: MessagesResponse(
                messages: olderMessages,
                myLastReadId: 1,
                hasMore: false,
              ),
            ),
          );
          when(() => mockRepository.markAsRead(10, any())).thenAnswer(
            (_) async => const ApiResponse.success(data: null),
          );
        },
        build: () => buildCubit(),
        act: (cubit) async {
          await cubit.loadMessages();
          await cubit.loadMoreMessages();
        },
        expect: () => [
          const ChatState.loading(),
          isA<ChatLoaded>().having((s) => s.hasMore, 'hasMore', true),
          isA<ChatLoaded>().having(
              (s) => s.isLoadingMore, 'isLoadingMore', true),
          isA<ChatLoaded>()
              .having((s) => s.messages.length, 'messages count', 3)
              .having((s) => s.hasMore, 'hasMore', false),
        ],
      );

      blocTest<ChatCubit, ChatState>(
        'does nothing when not in loaded state',
        build: () => buildCubit(),
        act: (cubit) => cubit.loadMoreMessages(),
        expect: () => [],
      );
    });

    group('sendMessage', () {
      blocTest<ChatCubit, ChatState>(
        'optimistically adds message then confirms on success',
        setUp: () {
          when(() => mockRepository.getMessages(
                10,
                limit: 20,
              )).thenAnswer(
            (_) async => ApiResponse.success(
              data: const MessagesResponse(
                messages: [],
                myLastReadId: 0,
              ),
            ),
          );
          when(() => mockRepository.sendMessage(10, 'Hello'))
              .thenAnswer(
            (_) async => ApiResponse.success(
              data: ChatMessage(
                id: 100,
                conversationId: 10,
                senderId: 1,
                content: 'Hello',
                createdAt: DateTime(2026, 1, 20, 11),
              ),
            ),
          );
        },
        build: () => buildCubit(),
        act: (cubit) async {
          await cubit.loadMessages();
          await cubit.sendMessage('Hello');
        },
        expect: () => [
          const ChatState.loading(),
          // Loaded with empty messages
          isA<ChatLoaded>()
              .having((s) => s.messages.length, 'messages', 0),
          // Optimistic: temp message added
          isA<ChatLoaded>()
              .having((s) => s.messages.length, 'messages', 1)
              .having((s) => s.pendingMessageIds.length, 'pending', 1),
          // Confirmed: real message replaces temp
          isA<ChatLoaded>()
              .having((s) => s.messages.length, 'messages', 1)
              .having((s) => s.pendingMessageIds.isEmpty, 'no pending', true)
              .having(
                  (s) => s.messages.first.id, 'real id', 100),
        ],
      );

      blocTest<ChatCubit, ChatState>(
        'sets sendingError on failure',
        setUp: () {
          when(() => mockRepository.getMessages(
                10,
                limit: 20,
              )).thenAnswer(
            (_) async => ApiResponse.success(
              data: const MessagesResponse(
                messages: [],
                myLastReadId: 0,
              ),
            ),
          );
          when(() => mockRepository.sendMessage(10, 'Hello'))
              .thenAnswer(
            (_) async =>
                const ApiResponse.error(message: 'Send failed'),
          );
        },
        build: () => buildCubit(),
        act: (cubit) async {
          await cubit.loadMessages();
          await cubit.sendMessage('Hello');
        },
        expect: () => [
          const ChatState.loading(),
          isA<ChatLoaded>(),
          // Optimistic add
          isA<ChatLoaded>()
              .having((s) => s.pendingMessageIds.length, 'pending', 1),
          // Error state
          isA<ChatLoaded>()
              .having((s) => s.sendingError, 'error', 'Send failed'),
        ],
      );

      blocTest<ChatCubit, ChatState>(
        'ignores empty or whitespace-only messages',
        setUp: () {
          when(() => mockRepository.getMessages(
                10,
                limit: 20,
              )).thenAnswer(
            (_) async => ApiResponse.success(
              data: const MessagesResponse(
                messages: [],
                myLastReadId: 0,
              ),
            ),
          );
        },
        build: () => buildCubit(),
        act: (cubit) async {
          await cubit.loadMessages();
          await cubit.sendMessage('   ');
        },
        expect: () => [
          const ChatState.loading(),
          isA<ChatLoaded>(),
        ],
      );
    });

    group('pollForNewMessages', () {
      blocTest<ChatCubit, ChatState>(
        'adds new messages from poll',
        setUp: () {
          // Use initialLastReadId high enough to skip markAsRead on load
          when(() => mockRepository.getMessages(
                10,
                limit: 20,
              )).thenAnswer(
            (_) async => ApiResponse.success(data: mockMessagesResponse),
          );
          when(() => mockRepository.markAsRead(10, any())).thenAnswer(
            (_) async => const ApiResponse.success(data: null),
          );
          final newMessage = ChatMessage(
            id: 3,
            conversationId: 10,
            senderId: 2,
            content: 'New message',
            createdAt: DateTime(2026, 1, 20, 11),
          );
          when(() => mockRepository.getMessages(
                10,
                afterId: 2,
              )).thenAnswer(
            (_) async => ApiResponse.success(
              data: MessagesResponse(
                messages: [newMessage],
                myLastReadId: 1,
              ),
            ),
          );
        },
        build: () => buildCubit(initialLastReadId: 99),
        act: (cubit) async {
          await cubit.loadMessages();
          await cubit.pollForNewMessages();
          // Wait for unawaited markAsRead from poll
          await Future<void>.delayed(Duration.zero);
        },
        expect: () => [
          const ChatState.loading(),
          isA<ChatLoaded>()
              .having((s) => s.messages.length, 'initial', 2),
          // After poll - 3 messages
          isA<ChatLoaded>()
              .having((s) => s.messages.length, 'after poll', 3),
          // After markAsRead updates myLastReadId
          isA<ChatLoaded>()
              .having((s) => s.messages.length, 'still 3', 3)
              .having((s) => s.myLastReadId, 'read id updated', 3),
        ],
      );
    });

    group('clearSendingError', () {
      blocTest<ChatCubit, ChatState>(
        'clears sending error from loaded state',
        setUp: () {
          when(() => mockRepository.getMessages(
                10,
                limit: 20,
              )).thenAnswer(
            (_) async => ApiResponse.success(
              data: const MessagesResponse(
                messages: [],
                myLastReadId: 0,
              ),
            ),
          );
          when(() => mockRepository.sendMessage(10, 'Hi')).thenAnswer(
            (_) async =>
                const ApiResponse.error(message: 'Failed'),
          );
        },
        build: () => buildCubit(),
        act: (cubit) async {
          await cubit.loadMessages();
          await cubit.sendMessage('Hi');
          cubit.clearSendingError();
        },
        expect: () => [
          const ChatState.loading(),
          isA<ChatLoaded>(),
          isA<ChatLoaded>()
              .having((s) => s.pendingMessageIds.length, 'pending', 1),
          isA<ChatLoaded>()
              .having((s) => s.sendingError, 'error', 'Failed'),
          isA<ChatLoaded>()
              .having((s) => s.sendingError, 'cleared', null),
        ],
      );
    });

    group('polling lifecycle', () {
      test('startPolling creates timer, stopPolling cancels it', () {
        final cubit = buildCubit();
        cubit.startPolling();
        // No exception = timer created
        cubit.stopPolling();
        cubit.close();
      });

      test('close cancels polling timer', () async {
        final cubit = buildCubit();
        cubit.startPolling();
        await cubit.close();
        // No exception = timer cancelled cleanly
      });
    });
  });

  group('ChatState', () {
    test('hasData returns true for loaded state', () {
      const loaded = ChatState.loaded(
        messages: [],
        myLastReadId: 0,
        hasMore: false,
        isLoadingMore: false,
      );
      expect(loaded.hasData, isTrue);
    });

    test('hasData returns false for non-loaded states', () {
      expect(const ChatState.initial().hasData, isFalse);
      expect(const ChatState.loading().hasData, isFalse);
      expect(const ChatState.error('err').hasData, isFalse);
    });

    test('messages returns list for loaded state', () {
      final msg = ChatMessage(
        id: 1,
        conversationId: 1,
        senderId: 1,
        content: 'test',
        createdAt: DateTime(2026),
      );
      final loaded = ChatState.loaded(
        messages: [msg],
        myLastReadId: 0,
        hasMore: false,
        isLoadingMore: false,
      );
      expect(loaded.messages, [msg]);
    });

    test('messages returns empty list for initial state', () {
      expect(const ChatState.initial().messages, isEmpty);
    });

    test('hasSendingError returns true when error present', () {
      const loaded = ChatState.loaded(
        messages: [],
        myLastReadId: 0,
        hasMore: false,
        isLoadingMore: false,
        sendingError: 'Failed',
      );
      expect(loaded.hasSendingError, isTrue);
      expect(loaded.sendingErrorMessage, 'Failed');
    });

    test('hasSendingError returns false when no error', () {
      const loaded = ChatState.loaded(
        messages: [],
        myLastReadId: 0,
        hasMore: false,
        isLoadingMore: false,
      );
      expect(loaded.hasSendingError, isFalse);
      expect(loaded.sendingErrorMessage, isNull);
    });

    test('pendingIds returns set for loaded state', () {
      const loaded = ChatState.loaded(
        messages: [],
        myLastReadId: 0,
        hasMore: false,
        isLoadingMore: false,
        pendingMessageIds: {1, 2},
      );
      expect(loaded.pendingIds, {1, 2});
    });

    test('pendingIds returns empty set for non-loaded states', () {
      expect(const ChatState.initial().pendingIds, isEmpty);
    });
  });
}
