import 'package:chat_app/core/constants/app_dimens.dart';
import 'package:chat_app/core/constants/app_durations.dart';
import 'package:chat_app/core/di/injection.dart';
import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/core/network/socket_service.dart';
import 'package:flutter/material.dart';

/// Thin strip shown while the realtime connection is down, so a screen
/// that has stopped updating explains itself.
class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final socketService = getIt<SocketService>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<SocketStatus>(
      stream: socketService.status,
      initialData: socketService.currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SocketStatus.disconnected;
        final isConnected = status == SocketStatus.connected;

        return AnimatedSize(
          duration: AppDurations.medium,
          curve: Curves.easeOutCubic,
          child: isConnected
              ? const SizedBox(width: double.infinity)
              : Container(
                  width: double.infinity,
                  color: scheme.surfaceContainerHighest,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimens.spaceXs,
                  ),
                  child: Text(
                    status == SocketStatus.connecting
                        ? l10n.connecting
                        : l10n.notConnected,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
        );
      },
    );
  }
}
