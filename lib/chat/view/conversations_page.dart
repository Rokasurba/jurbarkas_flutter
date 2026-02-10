import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/auth/cubit/auth_cubit.dart';
import 'package:frontend/chat/cubit/conversations_cubit.dart';
import 'package:frontend/chat/data/models/conversation.dart';
import 'package:frontend/chat/data/repositories/conversations_repository.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/data/models/patient_list_item.dart';
import 'package:frontend/patients/data/patients_repository.dart';
import 'package:intl/intl.dart';

@RoutePage()
class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;

    return BlocProvider(
      create: (context) {
        final cubit = ConversationsCubit(
          conversationsRepository: ConversationsRepository(
            apiClient: context.read<ApiClient>(),
          ),
          currentUserRole: authState.user?.role ?? '',
        );
        unawaited(cubit.loadConversations());
        return cubit;
      },
      child: const _ConversationsView(),
    );
  }
}

class _ConversationsView extends StatelessWidget {
  const _ConversationsView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ConversationsCubit>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 3,
        title: Text(
          l10n.conversationsTitle,
          style: context.appBarTitle,
        ),
      ),
      floatingActionButton: cubit.isDoctor
          ? FloatingActionButton.extended(
              heroTag: 'newConversationFab',
              onPressed: () => _showPatientSelector(context),
              icon: const Icon(Icons.edit),
              label: Text(l10n.conversationsNewMessage),
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: BlocSelector<ConversationsCubit, ConversationsState, bool>(
              selector: (state) => state is ConversationsLoaded,
              builder: (context, isLoaded) {
                return TextField(
                  enabled: isLoaded,
                  decoration: InputDecoration(
                    hintText: l10n.conversationsSearch,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: cubit.search,
                );
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<ConversationsCubit, ConversationsState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  loaded: (conversations, searchQuery, _) {
                    final filtered = state.filteredConversations;

                    if (conversations.isEmpty) {
                      return _EmptyState(message: l10n.conversationsEmpty);
                    }

                    if (filtered.isEmpty && searchQuery.isNotEmpty) {
                      return _EmptyState(message: l10n.conversationsEmpty);
                    }

                    return RefreshIndicator(
                      onRefresh: cubit.refresh,
                      child: ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, indent: 72),
                        itemBuilder: (context, index) {
                          final conversation = filtered[index];
                          return _ConversationTile(
                            conversation: conversation,
                            onTap: () => _navigateToChat(
                              context,
                              conversation,
                            ),
                          );
                        },
                      ),
                    );
                  },
                  error: (message) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          message,
                          style: TextStyle(color: context.errorColor),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        AppButton.primary(
                          label: l10n.retryButton,
                          icon: Icons.refresh,
                          onPressed: cubit.loadConversations,
                          expand: false,
                          size: AppButtonSize.medium,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToChat(
    BuildContext context,
    Conversation conversation,
  ) async {
    final currentUserId = context.read<AuthCubit>().state.user?.id ?? 0;

    await context.router.push(
      ChatRoute(
        conversationId: conversation.id,
        currentUserId: currentUserId,
        otherUser: conversation.otherUser,
        initialLastReadId: conversation.myLastReadId,
      ),
    );

    if (context.mounted) {
      unawaited(context.read<ConversationsCubit>().refresh());
    }
  }

  Future<void> _showPatientSelector(BuildContext context) async {
    final cubit = context.read<ConversationsCubit>();
    final patientsRepository = PatientsRepository(
      apiClient: context.read<ApiClient>(),
    );

    final result = await showModalBottomSheet<Conversation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (_) => _PatientSelectorSheet(
        patientsRepository: patientsRepository,
        conversationsCubit: cubit,
      ),
    );

    if (result != null && context.mounted) {
      await _navigateToChat(
        context,
        result,
      );
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: context.bodyLarge?.copyWith(
          color: Colors.grey,
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final otherUser = conversation.otherUser;
    final hasUnread = conversation.unreadCount > 0;
    final initials =
        '${otherUser.name.isNotEmpty ? otherUser.name[0] : ''}'
        '${otherUser.surname.isNotEmpty ? otherUser.surname[0] : ''}';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.secondary,
        child: Text(
          initials.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        '${otherUser.name} ${otherUser.surname}',
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: conversation.lastMessage != null
          ? Text(
              _truncateMessage(conversation.lastMessage!.content),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: hasUnread ? Colors.black87 : Colors.grey,
              ),
            )
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTimestamp(context, conversation.updatedAt),
            style: context.bodySmall?.copyWith(
              color: hasUnread ? AppColors.secondary : Colors.grey,
            ),
          ),
          if (hasUnread) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  String _truncateMessage(String content) {
    if (content.length <= 50) return content;
    return '${content.substring(0, 50)}...';
  }

  String _formatTimestamp(BuildContext context, DateTime dateTime) {
    final local = dateTime.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(local.year, local.month, local.day);

    if (messageDate == today) {
      return '${DateFormat('HH:mm').format(local)} val.';
    } else if (messageDate == yesterday) {
      return context.l10n.conversationsYesterday;
    } else {
      return DateFormat('yyyy-MM-dd').format(local);
    }
  }
}

class _PatientSelectorSheet extends StatefulWidget {
  const _PatientSelectorSheet({
    required this.patientsRepository,
    required this.conversationsCubit,
  });

  final PatientsRepository patientsRepository;
  final ConversationsCubit conversationsCubit;

  @override
  State<_PatientSelectorSheet> createState() => _PatientSelectorSheetState();
}

class _PatientSelectorSheetState extends State<_PatientSelectorSheet> {
  List<PatientListItem> _patients = [];
  List<PatientListItem> _filtered = [];
  bool _isLoading = true;
  bool _isCreating = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    unawaited(_loadPatients());
  }

  Future<void> _loadPatients() async {
    final response = await widget.patientsRepository.getPatients();

    if (!mounted) return;

    response.when(
      success: (data, _) {
        setState(() {
          _patients = data.patients;
          _filtered = data.patients;
          _isLoading = false;
        });
      },
      error: (message, _) {
        setState(() {
          _error = message;
          _isLoading = false;
        });
      },
    );
  }

  void _filterPatients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _patients;
      } else {
        _filtered = _patients
            .where(
              (p) => '${p.name} ${p.surname}'.toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  Future<void> _selectPatient(PatientListItem patient) async {
    setState(() => _isCreating = true);

    final conversation = await widget.conversationsCubit.createConversation(
      patient.id,
    );

    if (!mounted) return;

    if (conversation != null) {
      Navigator.of(context).pop(conversation);
    } else {
      setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.conversationsSelectPatient,
                    style: context.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: l10n.conversationsSearchPatients,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: _filterPatients,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                  ? Center(child: Text(_error))
                  : _isCreating
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final patient = _filtered[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.secondary,
                            child: Text(
                              patient.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            '${patient.name} ${patient.surname}',
                          ),
                          onTap: () => _selectPatient(patient),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
