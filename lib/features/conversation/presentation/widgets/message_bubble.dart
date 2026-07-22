import 'package:chat_app/core/constants/app_colors.dart';
import 'package:chat_app/core/constants/app_dimens.dart';
import 'package:chat_app/features/conversation/domain/entities/message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.message,
    required this.isMine,
    required this.onRetry,
    super.key,
  });

  final Message message;
  final bool isMine;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final failed = message.status == MessageStatus.failed;

    final background = isMine
        ? (failed ? scheme.errorContainer : scheme.primary)
        : scheme.surfaceContainerHighest;
    final foreground = isMine
        ? (failed ? scheme.onErrorContainer : scheme.onPrimary)
        : scheme.onSurface;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: failed ? onRetry : null,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width *
                AppDimens.bubbleMaxWidthFactor,
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: AppDimens.spaceM,
            vertical: AppDimens.spaceXs,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spaceM,
            vertical: AppDimens.spaceS,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppDimens.radiusL),
              topRight: const Radius.circular(AppDimens.radiusL),
              bottomLeft: Radius.circular(
                isMine ? AppDimens.radiusL : AppDimens.radiusXs,
              ),
              bottomRight: Radius.circular(
                isMine ? AppDimens.radiusXs : AppDimens.radiusL,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.content,
                style: theme.textTheme.bodyLarge?.copyWith(color: foreground),
              ),
              const SizedBox(height: AppDimens.spaceXs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat.jm().format(message.createdAt.toLocal()),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: foreground.withValues(alpha: 0.7),
                    ),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: AppDimens.spaceXs),
                    _StatusTicks(status: message.status, color: foreground),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single tick while sending, double once delivered, orange when read.
class _StatusTicks extends StatelessWidget {
  const _StatusTicks({required this.status, required this.color});

  final MessageStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      MessageStatus.sending => SizedBox.square(
          dimension: AppDimens.iconS,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: color.withValues(alpha: 0.7),
          ),
        ),
      MessageStatus.failed => Icon(
          Icons.error_outline_rounded,
          size: AppDimens.iconS,
          color: color,
        ),
      MessageStatus.sent => Icon(
          Icons.done_rounded,
          size: AppDimens.iconS,
          color: color.withValues(alpha: 0.7),
        ),
      MessageStatus.read => const Icon(
          Icons.done_all_rounded,
          size: AppDimens.iconS,
          color: AppColors.readReceipt,
        ),
    };
  }
}
