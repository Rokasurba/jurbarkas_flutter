import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/chat/cubit/conversations_cubit.dart';
import 'package:frontend/chat/data/models/chat_message.dart';
import 'package:frontend/chat/data/models/conversation.dart';
import 'package:frontend/chat/data/models/user_brief.dart';
import 'package:frontend/chat/data/repositories/conversations_repository.dart';
import 'package:frontend/core/data/api_response.dart';
import 'package:mocktail/mocktail.dart';

class MockConversationsRepository extends Mock
    implements ConversationsRepository {}

void main() {
  late MockConversationsRepository mockRepository;

  final conversation1 = Conversation(
    id: 1,
    otherUser: const UserBrief(
      id: 2,
      name: 'Jonas',
      surname: 'Jonaitis',
      role: 'doctor',
    ),
    unreadCount: 2,
    myLastReadId: 5,
    updatedAt: DateTime(2026, 1, 20, 10),
    lastMessage: ChatMessage(
      id: 10,
      conversationId: 1,
      senderId: 2,
      content: 'Hello patient',
      createdAt: DateTime(2026, 1, 20, 10),
    ),
  );

  final conversation2 = Conversation(
    id: 2,
    otherUser: const UserBrief(
      id: 3,
      name: 'Petras',
      surname: 'Petraitis',
      role: 'doctor',
    ),
    unreadCount: 0,
    myLastReadId: 20,
    updatedAt: DateTime(2026, 1, 21, 14),
  );

  final conversations = [conversation1, conversation2];

  setUp(() {
    mockRepository = MockConversationsRepository();
  });

  ConversationsCubit buildCubit({String role = 'patient'}) {
    return ConversationsCubit(
      conversationsRepository: mockRepository,
      currentUserRole: role,
    );
  }

  group('ConversationsCubit', () {
    test('initial state is ConversationsInitial', () {
      final cubit = buildCubit();
      expect(cubit.state, const ConversationsState.initial());
      cubit.close();
    });

    test('isDoctor returns true for doctor role', () {
      final cubit = buildCubit(role: 'doctor');
      expect(cubit.isDoctor, isTrue);
      cubit.close();
    });

    test('isDoctor returns false for patient role', () {
      final cubit = buildCubit();
      expect(cubit.isDoctor, isFalse);
      cubit.close();
    });

    group('loadConversations', () {
      blocTest<ConversationsCubit, ConversationsState>(
        'emits [loading, loaded] sorted by updatedAt desc on success',
        setUp: () {
          when(() => mockRepository.getConversations()).thenAnswer(
            (_) async => ApiResponse.success(data: conversations),
          );
        },
        build: () => buildCubit(),
        act: (cubit) => cubit.loadConversations(),
        expect: () => [
          const ConversationsState.loading(),
          isA<ConversationsLoaded>()
              .having(
                (s) => s.conversations.length,
                'count',
                2,
              )
              .having(
                (s) => s.conversations.first.id,
                'newest first',
                2,
              ),
        ],
      );

      blocTest<ConversationsCubit, ConversationsState>(
        'emits [loading, error] on failure',
        setUp: () {
          when(() => mockRepository.getConversations()).thenAnswer(
            (_) async =>
                const ApiResponse.error(message: 'Connection failed'),
          );
        },
        build: () => buildCubit(),
        act: (cubit) => cubit.loadConversations(),
        expect: () => [
          const ConversationsState.loading(),
          const ConversationsState.error('Connection failed'),
        ],
      );

      blocTest<ConversationsCubit, ConversationsState>(
        'emits loaded with empty list when no conversations',
        setUp: () {
          when(() => mockRepository.getConversations()).thenAnswer(
            (_) async => const ApiResponse.success(data: []),
          );
        },
        build: () => buildCubit(),
        act: (cubit) => cubit.loadConversations(),
        expect: () => [
          const ConversationsState.loading(),
          isA<ConversationsLoaded>()
              .having((s) => s.conversations, 'empty', isEmpty),
        ],
      );
    });

    group('search', () {
      blocTest<ConversationsCubit, ConversationsState>(
        'filters conversations by other user name',
        setUp: () {
          when(() => mockRepository.getConversations()).thenAnswer(
            (_) async => ApiResponse.success(data: conversations),
          );
        },
        build: () => buildCubit(),
        act: (cubit) async {
          await cubit.loadConversations();
          cubit.search('Jonas');
          // Wait for debounce
          await Future<void>.delayed(const Duration(milliseconds: 350));
        },
        expect: () => [
          const ConversationsState.loading(),
          isA<ConversationsLoaded>(),
          isA<ConversationsLoaded>()
              .having((s) => s.searchQuery, 'query', 'Jonas')
              .having(
                (s) => s.filteredConversations.length,
                'filtered',
                1,
              ),
        ],
      );

      blocTest<ConversationsCubit, ConversationsState>(
        'clears search immediately when empty query',
        setUp: () {
          when(() => mockRepository.getConversations()).thenAnswer(
            (_) async => ApiResponse.success(data: conversations),
          );
        },
        build: () => buildCubit(),
        act: (cubit) async {
          await cubit.loadConversations();
          cubit.search('Jonas');
          await Future<void>.delayed(const Duration(milliseconds: 350));
          cubit.search('');
        },
        expect: () => [
          const ConversationsState.loading(),
          isA<ConversationsLoaded>(),
          isA<ConversationsLoaded>()
              .having((s) => s.searchQuery, 'query', 'Jonas'),
          isA<ConversationsLoaded>()
              .having((s) => s.searchQuery, 'cleared', ''),
        ],
      );
    });

    group('clearSearch', () {
      blocTest<ConversationsCubit, ConversationsState>(
        'resets search query to empty',
        setUp: () {
          when(() => mockRepository.getConversations()).thenAnswer(
            (_) async => ApiResponse.success(data: conversations),
          );
        },
        build: () => buildCubit(),
        act: (cubit) async {
          await cubit.loadConversations();
          cubit.search('Jonas');
          await Future<void>.delayed(const Duration(milliseconds: 350));
          cubit.clearSearch();
        },
        expect: () => [
          const ConversationsState.loading(),
          isA<ConversationsLoaded>(),
          isA<ConversationsLoaded>()
              .having((s) => s.searchQuery, 'query', 'Jonas'),
          isA<ConversationsLoaded>()
              .having((s) => s.searchQuery, 'cleared', ''),
        ],
      );
    });

    group('refresh', () {
      test('reloads conversations preserving search query', () async {
        when(() => mockRepository.getConversations()).thenAnswer(
          (_) async => ApiResponse.success(data: conversations),
        );

        final cubit = buildCubit();
        await cubit.loadConversations();
        cubit.search('Jonas');
        await Future<void>.delayed(const Duration(milliseconds: 350));

        // Verify search query is set
        final stateBeforeRefresh = cubit.state as ConversationsLoaded;
        expect(stateBeforeRefresh.searchQuery, 'Jonas');

        await cubit.refresh();

        // Verify search query preserved after refresh
        final stateAfterRefresh = cubit.state as ConversationsLoaded;
        expect(stateAfterRefresh.searchQuery, 'Jonas');
        expect(stateAfterRefresh.conversations.length, 2);

        verify(() => mockRepository.getConversations()).called(2);
        await cubit.close();
      });

      blocTest<ConversationsCubit, ConversationsState>(
        'keeps current state on refresh failure',
        setUp: () {
          var callCount = 0;
          when(() => mockRepository.getConversations()).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              return ApiResponse.success(data: conversations);
            }
            return const ApiResponse.error(message: 'Network error');
          });
        },
        build: () => buildCubit(),
        act: (cubit) async {
          await cubit.loadConversations();
          await cubit.refresh();
        },
        expect: () => [
          const ConversationsState.loading(),
          isA<ConversationsLoaded>()
              .having((s) => s.conversations.length, 'count', 2),
          // No new emission on failure - state preserved
        ],
      );
    });

    group('createConversation', () {
      test('returns conversation on success', () async {
        when(() => mockRepository.getConversations()).thenAnswer(
          (_) async => ApiResponse.success(data: conversations),
        );
        when(() => mockRepository.createConversation(5)).thenAnswer(
          (_) async => ApiResponse.success(data: conversation1),
        );

        final cubit = buildCubit(role: 'doctor');
        await cubit.loadConversations();

        final result = await cubit.createConversation(5);

        expect(result, isNotNull);
        expect(result!.id, 1);
        verify(() => mockRepository.createConversation(5)).called(1);

        await cubit.close();
      });

      test('returns null on failure', () async {
        when(() => mockRepository.getConversations()).thenAnswer(
          (_) async => ApiResponse.success(data: conversations),
        );
        when(() => mockRepository.createConversation(5)).thenAnswer(
          (_) async => const ApiResponse.error(message: 'Failed'),
        );

        final cubit = buildCubit(role: 'doctor');
        await cubit.loadConversations();

        final result = await cubit.createConversation(5);

        expect(result, isNull);

        await cubit.close();
      });
    });

    group('close', () {
      test('cancels debounce timer', () async {
        final cubit = buildCubit();
        cubit.search('test'); // starts debounce timer
        await cubit.close();
        // No exception = timer cancelled cleanly
      });
    });
  });

  group('ConversationsState', () {
    test('filteredConversations returns all when no search query', () {
      final state = ConversationsState.loaded(
        conversations: conversations,
      );
      expect(state.filteredConversations.length, 2);
    });

    test('filteredConversations filters by name', () {
      final state = ConversationsState.loaded(
        conversations: conversations,
        searchQuery: 'Petras',
      );
      expect(state.filteredConversations.length, 1);
      expect(state.filteredConversations.first.id, 2);
    });

    test('filteredConversations returns empty for non-loaded states', () {
      expect(
        const ConversationsState.initial().filteredConversations,
        isEmpty,
      );
      expect(
        const ConversationsState.loading().filteredConversations,
        isEmpty,
      );
    });

    test('isEmpty returns true for empty loaded state', () {
      const state = ConversationsState.loaded(conversations: []);
      expect(state.isEmpty, isTrue);
    });

    test('isEmpty returns false for non-empty loaded state', () {
      final state = ConversationsState.loaded(
        conversations: conversations,
      );
      expect(state.isEmpty, isFalse);
    });

    test('isEmpty returns false for non-loaded states', () {
      expect(const ConversationsState.initial().isEmpty, isFalse);
    });
  });
}
