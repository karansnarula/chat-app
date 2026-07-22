import 'package:chat_app/core/constants/app_dimens.dart';
import 'package:chat_app/core/di/injection.dart';
import 'package:chat_app/core/error/app_exception.dart';
import 'package:chat_app/core/error/app_exception_l10n.dart';
import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/core/widgets/app_state_view.dart';
import 'package:chat_app/features/conversation/presentation/bloc/conversation_bloc.dart';
import 'package:chat_app/features/conversation/presentation/widgets/date_separator.dart';
import 'package:chat_app/features/conversation/presentation/widgets/message_bubble.dart';
import 'package:chat_app/features/conversation/presentation/widgets/message_composer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationScreen extends StatelessWidget {
  const ConversationScreen({
    required this.conversationId,
    required this.title,
    super.key,
  });

  final String conversationId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConversationBloc>(param1: conversationId)
        ..add(const ConversationOpened()),
      child: _ConversationView(title: title),
    );
  }
}

class _ConversationView extends StatefulWidget {
  const _ConversationView({required this.title});

  final String title;

  @override
  State<_ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<_ConversationView> {
  final _scrollController = ScrollController();

  /// Distance from the top of the reversed list at which older messages
  /// start loading.
  static const _loadOlderThreshold = 300.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadOlderThreshold) {
      context.read<ConversationBloc>().add(
            const ConversationOlderPageRequested(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ConversationBloc, ConversationState>(
              builder: (context, state) => switch (state.status) {
                ConversationStatus.loading =>
                  const Center(child: CircularProgressIndicator()),
                ConversationStatus.failure =>
                  _ConversationFailure(failure: state.failure!),
                ConversationStatus.success when state.isEmpty =>
                  const _NoMessages(),
                ConversationStatus.success => _MessageList(
                    state: state,
                    controller: _scrollController,
                  ),
              },
            ),
          ),
          SafeArea(
            top: false,
            child: MessageComposer(
              onSend: (content) => context.read<ConversationBloc>().add(
                    ConversationMessageSent(content),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.state, required this.controller});

  final ConversationState state;
  final ScrollController controller;

  /// True when the message at [index] starts a new calendar day relative
  /// to the older message that follows it in this newest-first list.
  bool _startsNewDay(int index) {
    if (index == state.messages.length - 1) return true;
    final current = state.messages[index].createdAt.toLocal();
    final older = state.messages[index + 1].createdAt.toLocal();
    return current.day != older.day ||
        current.month != older.month ||
        current.year != older.year;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceS),
      itemCount: state.messages.length + (state.isLoadingOlder ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.messages.length) {
          return const Padding(
            padding: EdgeInsets.all(AppDimens.spaceM),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final message = state.messages[index];
        final bubble = MessageBubble(
          message: message,
          isMine: state.isMine(message),
          onRetry: () => context.read<ConversationBloc>().add(
                ConversationMessageRetried(message.id),
              ),
        );

        if (!_startsNewDay(index)) return bubble;

        // Reversed list: the separator renders below its message, which
        // reads as above it on screen.
        return Column(
          children: [
            DateSeparator(date: message.createdAt.toLocal()),
            bubble,
          ],
        );
      },
    );
  }
}

class _NoMessages extends StatelessWidget {
  const _NoMessages();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppStateView(
      icon: Icons.waving_hand_outlined,
      title: l10n.noMessagesTitle,
      message: l10n.noMessagesMessage,
    );
  }
}

class _ConversationFailure extends StatelessWidget {
  const _ConversationFailure({required this.failure});

  final AppException failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isOffline = failure is NetworkException;

    return AppStateView(
      icon: isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
      title: isOffline ? l10n.errorNetworkTitle : l10n.errorGenericTitle,
      message: failure.localizedMessage(l10n),
      onRetry: () =>
          context.read<ConversationBloc>().add(const ConversationOpened()),
    );
  }
}
