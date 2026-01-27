part of 'chat_cubit.dart';

@freezed
sealed class ChatState with _$ChatState {
  const ChatState._();

  const factory ChatState.initial() = ChatInitial;

  const factory ChatState.loading() = ChatLoading;

  const factory ChatState.loaded({
    required List<ChatMessage> messages,
    required int myLastReadId,
    required bool hasMore,
    required bool isLoadingMore,
    @Default(null) String? sendingError,
    @Default({}) Set<int> pendingMessageIds,
  }) = ChatLoaded;

  const factory ChatState.error(String message) = ChatError;

  /// Returns true if this state has messages data.
  bool get hasData => this is ChatLoaded;

  /// Returns the messages if loaded, empty list otherwise.
  List<ChatMessage> get messages => switch (this) {
        ChatLoaded(messages: final m) => m,
        _ => [],
      };

  /// Returns true if currently loading more messages.
  bool get isLoadingMoreMessages => switch (this) {
        ChatLoaded(isLoadingMore: final loading) => loading,
        _ => false,
      };

  /// Returns true if there's a sending error.
  bool get hasSendingError => switch (this) {
        ChatLoaded(sendingError: final error) => error != null,
        _ => false,
      };

  /// Returns the sending error message if any.
  String? get sendingErrorMessage => switch (this) {
        ChatLoaded(sendingError: final error) => error,
        _ => null,
      };

  /// Returns the set of pending message IDs (optimistic sends).
  Set<int> get pendingIds => switch (this) {
        ChatLoaded(pendingMessageIds: final ids) => ids,
        _ => {},
      };
}
