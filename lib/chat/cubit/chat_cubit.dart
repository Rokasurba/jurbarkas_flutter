import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/chat/data/models/chat_message.dart';
import 'package:frontend/chat/data/models/user_brief.dart';
import 'package:frontend/chat/data/repositories/chat_repository.dart';

part 'chat_state.dart';
part 'chat_cubit.freezed.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required int conversationId,
    required int currentUserId,
    required UserBrief otherUser,
    required ChatRepository chatRepository,
    int initialLastReadId = 0,
  })  : _conversationId = conversationId,
        _currentUserId = currentUserId,
        _otherUser = otherUser,
        _chatRepository = chatRepository,
        _myLastReadId = initialLastReadId,
        super(const ChatState.initial());

  final int _conversationId;
  final int _currentUserId;
  final UserBrief _otherUser;
  final ChatRepository _chatRepository;

  Timer? _pollingTimer;
  int? _lastMessageId;
  int _myLastReadId;

  /// The other user in this conversation
  UserBrief get otherUser => _otherUser;

  /// The current user's ID
  int get currentUserId => _currentUserId;

  /// The conversation ID
  int get conversationId => _conversationId;

  /// Loads initial messages for the conversation.
  Future<void> loadMessages() async {
    emit(const ChatState.loading());

    final response = await _chatRepository.getMessages(
      _conversationId,
      limit: 20,
    );

    response.when(
      success: (data, _) {
        _myLastReadId = data.myLastReadId;
        if (data.messages.isNotEmpty) {
          _lastMessageId = data.messages
              .map((m) => m.id)
              .reduce((a, b) => a > b ? a : b);
        }

        emit(ChatState.loaded(
          messages: data.messages,
          myLastReadId: data.myLastReadId,
          hasMore: data.hasMore,
          isLoadingMore: false,
        ));

        // Mark messages as read if there are unread ones
        _markAsReadIfNeeded(data.messages);
      },
      error: (message, _) => emit(ChatState.error(message)),
    );
  }

  /// Loads older messages when scrolling up.
  Future<void> loadMoreMessages() async {
    final currentState = state;
    if (currentState is! ChatLoaded || currentState.isLoadingMore) return;
    if (!currentState.hasMore) return;

    final messages = currentState.messages;
    if (messages.isEmpty) return;

    // Get the oldest message ID (smallest id)
    final oldestId = messages.map((m) => m.id).reduce((a, b) => a < b ? a : b);

    emit(currentState.copyWith(isLoadingMore: true));

    final response = await _chatRepository.getMessages(
      _conversationId,
      limit: 20,
      beforeId: oldestId,
    );

    response.when(
      success: (data, _) {
        final allMessages = [...data.messages, ...messages];
        emit(ChatState.loaded(
          messages: allMessages,
          myLastReadId: currentState.myLastReadId,
          hasMore: data.hasMore,
          isLoadingMore: false,
        ));
      },
      error: (message, _) {
        emit(currentState.copyWith(isLoadingMore: false));
      },
    );
  }

  /// Sends a message with optimistic UI update.
  Future<void> sendMessage(String content) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) return;

    // Create temporary message for optimistic UI
    final tempId = DateTime.now().millisecondsSinceEpoch;
    final tempMessage = ChatMessage(
      id: tempId,
      conversationId: _conversationId,
      senderId: _currentUserId,
      content: trimmedContent,
      createdAt: DateTime.now(),
    );

    // Add to UI immediately
    emit(currentState.copyWith(
      messages: [...currentState.messages, tempMessage],
      pendingMessageIds: {...currentState.pendingMessageIds, tempId},
      sendingError: null,
    ));

    // Send to API
    final response = await _chatRepository.sendMessage(
      _conversationId,
      trimmedContent,
    );

    if (isClosed) return;
    final updatedState = state;
    if (updatedState is! ChatLoaded) return;

    response.when(
      success: (realMessage, _) {
        // Replace temp message with real one
        _lastMessageId = realMessage.id;
        final newPending = Set<int>.from(updatedState.pendingMessageIds)
          ..remove(tempId);

        emit(updatedState.copyWith(
          messages: updatedState.messages
              .map((m) => m.id == tempId ? realMessage : m)
              .toList(),
          pendingMessageIds: newPending,
          sendingError: null,
        ));
      },
      error: (message, _) {
        // Mark message as failed - keep it in list but track error
        emit(updatedState.copyWith(
          sendingError: message,
        ));
      },
    );
  }

  /// Retries sending a failed message.
  Future<void> retrySendMessage(int tempId) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final message =
        currentState.messages.where((m) => m.id == tempId).firstOrNull;
    if (message == null) return;

    // Remove old temp message and send again
    emit(currentState.copyWith(
      messages: currentState.messages.where((m) => m.id != tempId).toList(),
      pendingMessageIds: currentState.pendingMessageIds
          .where((id) => id != tempId)
          .toSet(),
      sendingError: null,
    ));

    await sendMessage(message.content);
  }

  /// Clears the sending error state.
  void clearSendingError() {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    emit(currentState.copyWith(sendingError: null));
  }

  /// Polls for new messages using after_id.
  Future<void> pollForNewMessages() async {
    if (_lastMessageId == null) return;
    if (isClosed) return;

    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final response = await _chatRepository.getMessages(
      _conversationId,
      afterId: _lastMessageId,
    );

    if (isClosed) return;

    response.when(
      success: (data, _) {
        if (data.messages.isNotEmpty) {
          final latestState = state;
          if (latestState is! ChatLoaded) return;

          // Filter out any messages we sent (already in list as pending)
          final newMessages = data.messages
              .where((m) =>
                  !latestState.messages.any((existing) => existing.id == m.id))
              .toList();

          if (newMessages.isNotEmpty) {
            _lastMessageId = data.messages
                .map((m) => m.id)
                .reduce((a, b) => a > b ? a : b);

            emit(latestState.copyWith(
              messages: [...latestState.messages, ...newMessages],
              myLastReadId: data.myLastReadId,
            ));

            // Mark new messages as read
            _markAsReadIfNeeded(newMessages);
          }
        }
      },
      error: (message, errors) {},
    );
  }

  /// Marks messages as read if there are unread ones.
  void _markAsReadIfNeeded(List<ChatMessage> messages) {
    if (messages.isEmpty) return;

    // Find the newest message from the other user
    final newestFromOther = messages
        .where((m) => m.senderId != _currentUserId && m.id > _myLastReadId)
        .fold<int?>(null, (max, m) => max == null || m.id > max ? m.id : max);

    if (newestFromOther != null) {
      unawaited(_markAsRead(newestFromOther));
    }
  }

  /// Marks messages as read up to the given ID.
  Future<void> _markAsRead(int lastReadId) async {
    if (lastReadId <= _myLastReadId) return;

    final response = await _chatRepository.markAsRead(
      _conversationId,
      lastReadId,
    );

    if (isClosed) return;

    response.when(
      success: (data, message) {
        _myLastReadId = lastReadId;
        final latestState = state;
        if (latestState is ChatLoaded) {
          emit(latestState.copyWith(myLastReadId: lastReadId));
        }
      },
      error: (message, errors) {},
    );
  }

  /// Starts polling for new messages.
  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 12),
      (_) => pollForNewMessages(),
    );
  }

  /// Stops polling for new messages.
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  Future<void> close() {
    stopPolling();
    return super.close();
  }
}
