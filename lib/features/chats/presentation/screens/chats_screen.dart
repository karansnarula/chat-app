import 'package:chat_app/core/constants/app_dimens.dart';
import 'package:chat_app/core/di/injection.dart';
import 'package:chat_app/core/error/app_exception.dart';
import 'package:chat_app/core/error/app_exception_l10n.dart';
import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/core/router/app_routes.dart';
import 'package:chat_app/core/widgets/app_state_view.dart';
import 'package:chat_app/features/chats/domain/entities/conversation.dart';
import 'package:chat_app/features/chats/presentation/bloc/chats_bloc.dart';
import 'package:chat_app/features/chats/presentation/widgets/conversation_list_skeleton.dart';
import 'package:chat_app/features/chats/presentation/widgets/conversation_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChatsBloc>()..add(const ChatsRequested()),
      child: const _ChatsView(),
    );
  }
}

class _ChatsView extends StatelessWidget {
  const _ChatsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chats),
        actions: [
          IconButton(
            tooltip: l10n.friendRequests,
            icon: const Icon(Icons.person_add_alt_1_outlined),
            onPressed: () => context.go(AppRoutes.friendRequests),
          ),
        ],
      ),
      body: BlocBuilder<ChatsBloc, ChatsState>(
        builder: (context, state) => switch (state.status) {
          ChatsStatus.loading => const ConversationListSkeleton(),
          ChatsStatus.failure => _ChatsFailure(failure: state.failure!),
          ChatsStatus.success when state.isEmpty => const _ChatsEmpty(),
          ChatsStatus.success => _ConversationList(
              conversations: state.conversations,
            ),
        },
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({required this.conversations});

  final List<Conversation> conversations;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<ChatsBloc>().add(const ChatsRefreshed()),
      child: ListView.separated(
        padding: const EdgeInsets.only(
          top: AppDimens.spaceS,
          bottom: AppDimens.navBarClearance,
        ),
        itemCount: conversations.length,
        separatorBuilder: (_, _) => const Divider(
          height: 1,
          indent: AppDimens.spaceXxl + AppDimens.spaceM,
        ),
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return ConversationTile(
            conversation: conversation,
            onTap: () =>
                context.push(AppRoutes.conversationWithId(conversation.id)),
          );
        },
      ),
    );
  }
}

class _ChatsEmpty extends StatelessWidget {
  const _ChatsEmpty();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppStateView(
      icon: Icons.forum_outlined,
      title: l10n.noChatsTitle,
      message: l10n.noChatsMessage,
    );
  }
}

class _ChatsFailure extends StatelessWidget {
  const _ChatsFailure({required this.failure});

  final AppException failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isOffline = failure is NetworkException;

    return AppStateView(
      icon: isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
      title: isOffline ? l10n.errorNetworkTitle : l10n.errorGenericTitle,
      message: failure.localizedMessage(l10n),
      onRetry: () => context.read<ChatsBloc>().add(const ChatsRequested()),
    );
  }
}
