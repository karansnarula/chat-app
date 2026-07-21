import 'package:chat_app/core/constants/app_dimens.dart';
import 'package:chat_app/core/constants/app_font_sizes.dart';
import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/features/chats/domain/entities/conversation.dart';
import 'package:chat_app/features/chats/presentation/message_timestamp.dart';
import 'package:flutter/material.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    required this.conversation,
    required this.onTap,
    super.key,
  });

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final lastMessage = conversation.lastMessage;
    final hasUnread = conversation.hasUnread;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceM,
        vertical: AppDimens.spaceXs,
      ),
      leading: CircleAvatar(
        radius: AppDimens.avatarRadius,
        backgroundColor: scheme.primaryContainer,
        child: Text(
          conversation.otherUser.initial,
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.onPrimaryContainer,
          ),
        ),
      ),
      title: Text(
        conversation.otherUser.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        lastMessage?.content ?? l10n.noMessagesYet,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: hasUnread ? scheme.onSurface : scheme.onSurfaceVariant,
          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (lastMessage != null)
            Text(
              formatMessageTimestamp(lastMessage.createdAt, l10n),
              style: theme.textTheme.labelSmall?.copyWith(
                color: hasUnread ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: AppDimens.spaceXs),
          if (hasUnread) _UnreadBadge(count: conversation.unreadCount),
        ],
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  static const _maxDisplayed = 99;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = count > _maxDisplayed ? '$_maxDisplayed+' : '$count';

    return Container(
      constraints: const BoxConstraints(minWidth: AppDimens.unreadBadgeSize),
      height: AppDimens.unreadBadgeSize,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceXs),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      // widthFactor keeps the badge hugging its label; a plain alignment
      // would stretch it across the unbounded trailing slot.
      child: Center(
        widthFactor: 1,
        child: Text(
          label,
          style: TextStyle(
            color: scheme.onPrimary,
            fontSize: AppFontSizes.xs,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
