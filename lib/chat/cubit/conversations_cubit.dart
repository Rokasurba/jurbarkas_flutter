import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/chat/data/models/conversation.dart';
import 'package:frontend/chat/data/repositories/conversations_repository.dart';

part 'conversations_state.dart';
part 'conversations_cubit.freezed.dart';

class ConversationsCubit extends Cubit<ConversationsState> {
  ConversationsCubit({
    required ConversationsRepository conversationsRepository,
    required String currentUserRole,
  })  : _conversationsRepository = conversationsRepository,
        _currentUserRole = currentUserRole,
        super(const ConversationsState.initial());

  final ConversationsRepository _conversationsRepository;
  final String _currentUserRole;
  Timer? _debounce;

  static const Duration _debounceDuration = Duration(milliseconds: 300);

  /// Whether the current user is a doctor.
  bool get isDoctor => _currentUserRole == 'doctor';

  /// Loads all conversations from the API.
  Future<void> loadConversations() async {
    emit(const ConversationsState.loading());

    final response = await _conversationsRepository.getConversations();

    if (isClosed) return;

    response.when(
      success: (conversations, _) {
        // Sort by updatedAt descending (newest first)
        final sorted = List<Conversation>.from(conversations)
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        emit(ConversationsState.loaded(conversations: sorted));
      },
      error: (message, _) => emit(ConversationsState.error(message)),
    );
  }

  /// Searches conversations by other user name with 300ms debounce.
  void search(String query) {
    _debounce?.cancel();

    if (query.isEmpty) {
      _performSearch(query);
      return;
    }

    _debounce = Timer(_debounceDuration, () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    final currentState = state;
    if (currentState is! ConversationsLoaded) return;

    emit(currentState.copyWith(searchQuery: query));
  }

  /// Clears the search filter.
  void clearSearch() {
    final currentState = state;
    if (currentState is! ConversationsLoaded) return;

    emit(currentState.copyWith(searchQuery: ''));
  }

  /// Refreshes conversations (e.g., when returning from chat).
  Future<void> refresh() async {
    final currentState = state;
    final previousQuery =
        currentState is ConversationsLoaded ? currentState.searchQuery : '';

    final response = await _conversationsRepository.getConversations();

    if (isClosed) return;

    response.when(
      success: (conversations, _) {
        final sorted = List<Conversation>.from(conversations)
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        emit(ConversationsState.loaded(
          conversations: sorted,
          searchQuery: previousQuery,
        ));
      },
      error: (_, _) {
        // On refresh failure, keep current state
      },
    );
  }

  /// Creates or retrieves a conversation with the given user (doctor flow).
  Future<Conversation?> createConversation(int userId) async {
    final currentState = state;
    if (currentState is ConversationsLoaded) {
      emit(currentState.copyWith(isCreatingConversation: true));
    }

    final response =
        await _conversationsRepository.createConversation(userId);

    if (isClosed) return null;

    return response.when(
      success: (conversation, _) {
        // Refresh the list to include the new/existing conversation
        unawaited(refresh());
        return conversation;
      },
      error: (_, _) {
        final latestState = state;
        if (latestState is ConversationsLoaded) {
          emit(latestState.copyWith(isCreatingConversation: false));
        }
        return null;
      },
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
