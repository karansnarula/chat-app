import 'package:chat_app/core/constants/app_dimens.dart';
import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/features/friend_requests/domain/entities/friend_request.dart';
import 'package:flutter/material.dart';

class FriendRequestTile extends StatelessWidget {
  const FriendRequestTile({
    required this.request,
    required this.isProcessing,
    required this.onRespond,
    super.key,
  });

  final FriendRequest request;
  final bool isProcessing;
  final ValueChanged<RequestResponse> onRespond;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceM,
        vertical: AppDimens.spaceM,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: AppDimens.avatarRadius,
            backgroundColor: scheme.primaryContainer,
            child: Text(
              request.sender.initial,
              style: theme.textTheme.titleLarge?.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.sender.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  request.sender.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.spaceS),
          if (isProcessing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimens.spaceM),
              child: SizedBox.square(
                dimension: AppDimens.iconM,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Row(
              children: [
                IconButton.filled(
                  tooltip: l10n.accept,
                  onPressed: () => onRespond(RequestResponse.accept),
                  icon: const Icon(Icons.check_rounded),
                ),
                const SizedBox(width: AppDimens.spaceXs),
                IconButton.outlined(
                  tooltip: l10n.decline,
                  onPressed: () => onRespond(RequestResponse.decline),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
