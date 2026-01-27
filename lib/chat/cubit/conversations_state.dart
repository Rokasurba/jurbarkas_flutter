part of 'conversations_cubit.dart';

@freezed
sealed class ConversationsState with _$ConversationsState {
  const ConversationsState._();

  const factory ConversationsState.initial() = ConversationsInitial;

  const factory ConversationsState.loading() = ConversationsLoading;

  const factory ConversationsState.loaded({
    required List<Conversation> conversations,
    @Default('') String searchQuery,
    @Default(false) bool isCreatingConversation,
  }) = ConversationsLoaded;

  const factory ConversationsState.error(String message) = ConversationsError;

  /// Returns conversations filtered by current search query.
  List<Conversation> get filteredConversations => switch (this) {
        ConversationsLoaded(
          conversations: final all,
          searchQuery: final query,
        ) =>
          query.isEmpty
              ? all
              : all
                  .where(
                    (c) =>
                        '${c.otherUser.name} ${c.otherUser.surname}'
                            .toLowerCase()
                            .contains(query.toLowerCase()),
                  )
                  .toList(),
        _ => [],
      };

  /// Returns true if there are no conversations at all.
  bool get isEmpty => switch (this) {
        ConversationsLoaded(conversations: final all) => all.isEmpty,
        _ => false,
      };
}
