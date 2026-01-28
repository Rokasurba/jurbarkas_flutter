import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:frontend/chat/cubit/chat_cubit.dart' as chat;
import 'package:frontend/chat/data/models/chat_message.dart';
import 'package:frontend/chat/data/models/user_brief.dart';
import 'package:frontend/chat/data/repositories/chat_repository.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:intl/intl.dart';

@RoutePage()
class ChatPage extends StatelessWidget {
  const ChatPage({
    required this.conversationId,
    required this.currentUserId,
    required this.otherUser,
    this.initialLastReadId = 0,
    super.key,
  });

  final int conversationId;
  final int currentUserId;
  final UserBrief otherUser;
  final int initialLastReadId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = chat.ChatCubit(
          conversationId: conversationId,
          currentUserId: currentUserId,
          otherUser: otherUser,
          chatRepository: ChatRepository(
            apiClient: context.read<ApiClient>(),
          ),
          initialLastReadId: initialLastReadId,
        );
        unawaited(cubit.loadMessages());
        cubit.startPolling();
        return cubit;
      },
      child: _ChatView(otherUser: otherUser),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView({required this.otherUser});

  final UserBrief otherUser;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  late types.User _currentUser;
  late types.User _otherUserChat;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<chat.ChatCubit>();
    _currentUser = types.User(
      id: cubit.currentUserId.toString(),
    );
    _otherUserChat = types.User(
      id: widget.otherUser.id.toString(),
      firstName: widget.otherUser.name,
      lastName: widget.otherUser.surname,
    );
  }

  void _handleSendPressed(types.PartialText message) {
    unawaited(context.read<chat.ChatCubit>().sendMessage(message.text));
  }

  Future<void> _handleEndReached() async {
    await context.read<chat.ChatCubit>().loadMoreMessages();
  }

  types.TextMessage _mapToFlutterChatMessage(ChatMessage message) {
    final isMine =
        message.senderId == _currentUser.id.hashCode ||
        message.senderId.toString() == _currentUser.id;

    return types.TextMessage(
      author: isMine ? _currentUser : _otherUserChat,
      createdAt: message.createdAt.millisecondsSinceEpoch,
      id: message.id.toString(),
      text: message.content,
    );
  }

  String _formatDateHeader(DateTime date) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return l10n.chatToday;
    } else if (messageDate == yesterday) {
      return l10n.chatYesterday;
    } else {
      return DateFormat('yyyy-MM-dd').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<chat.ChatCubit, chat.ChatState>(
      listener: (context, state) {
        if (state.hasSendingError) {
          context.showErrorSnackbar(
            state.sendingErrorMessage ?? l10n.chatMessageFailed,
          );
          context.read<chat.ChatCubit>().clearSendingError();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.router.maybePop(),
            ),
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 18,
                  child: Text(
                    _getInitials(widget.otherUser),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${widget.otherUser.name} ${widget.otherUser.surname}',
                    style: context.appBarTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              loaded:
                  (
                    List<ChatMessage> messages,
                    int myLastReadId,
                    bool hasMore,
                    bool isLoadingMore,
                    String? sendingError,
                    Set<int> pendingIds,
                  ) {
                    if (messages.isEmpty) {
                      return _EmptyChatView(
                        onSendPressed: _handleSendPressed,
                        placeholder: l10n.chatSendPlaceholder,
                      );
                    }

                    // Convert and reverse messages
                    // (flutter_chat_ui expects newest first)
                    final chatMessages = messages
                        .map(_mapToFlutterChatMessage)
                        .toList()
                        .reversed
                        .toList();

                    return Chat(
                      messages: chatMessages,
                      onSendPressed: _handleSendPressed,
                      onEndReached: hasMore ? _handleEndReached : null,
                      user: _currentUser,
                      customDateHeaderText: _formatDateHeader,
                      customBottomWidget: _ChatInput(
                        onSendPressed: _handleSendPressed,
                        placeholder: l10n.chatSendPlaceholder,
                      ),
                      theme: const DefaultChatTheme(
                        primaryColor: AppColors.secondary,
                        secondaryColor: AppColors.secondaryLight,
                        backgroundColor: AppColors.background,
                        sentMessageBodyTextStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        receivedMessageBodyTextStyle: TextStyle(
                          color: AppColors.mainText,
                          fontSize: 16,
                        ),
                        messageBorderRadius: 16,
                        messageInsetsHorizontal: 12,
                        messageInsetsVertical: 8,
                      ),
                      l10n: ChatL10nLt(
                        inputPlaceholder: l10n.chatSendPlaceholder,
                      ),
                      emptyState: Center(
                        child: Text(
                          l10n.chatNoMessages,
                          style: const TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
              error: (String message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => unawaited(
                        context.read<chat.ChatCubit>().loadMessages(),
                      ),
                      child: Text(l10n.retryButton),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getInitials(UserBrief user) {
    final first = user.name.isNotEmpty ? user.name[0].toUpperCase() : '';
    final last = user.surname.isNotEmpty ? user.surname[0].toUpperCase() : '';
    return '$first$last';
  }
}

class _EmptyChatView extends StatelessWidget {
  const _EmptyChatView({
    required this.onSendPressed,
    required this.placeholder,
  });

  final void Function(types.PartialText) onSendPressed;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: AppColors.secondaryText.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.chatStartConversation,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        _ChatInput(
          onSendPressed: onSendPressed,
          placeholder: placeholder,
        ),
      ],
    );
  }
}

class _ChatInput extends StatefulWidget {
  const _ChatInput({
    required this.onSendPressed,
    required this.placeholder,
  });

  final void Function(types.PartialText) onSendPressed;
  final String placeholder;

  @override
  State<_ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<_ChatInput> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSendPressed(types.PartialText(text: text));
      _controller.clear();
    }
  }

  @override 
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 12,
        bottom: 12 + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: TextStyle(
                  color: AppColors.secondaryText.withValues(alpha: 0.6),
                ),
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _hasText ? _handleSend : null,
            icon: Icon(
              Icons.send,
              color: _hasText ? AppColors.primary : AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lithuanian localization for flutter_chat_ui
@immutable
class ChatL10nLt extends ChatL10n {
  const ChatL10nLt({
    super.and = 'ir',
    super.attachmentButtonAccessibilityLabel = 'Pridėti priedą',
    super.emptyChatPlaceholder = 'Nėra žinučių',
    super.fileButtonAccessibilityLabel = 'Failas',
    super.inputPlaceholder = 'Rašykite žinutę...',
    super.isTyping = 'rašo...',
    super.others = 'kiti',
    super.sendButtonAccessibilityLabel = 'Siųsti',
    super.unreadMessagesLabel = 'Neperskaityti pranešimai',
  });
}
