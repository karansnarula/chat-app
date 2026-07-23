import 'package:chat_app/core/constants/app_dimens.dart';
import 'package:chat_app/core/constants/app_durations.dart';
import 'package:chat_app/core/di/injection.dart';
import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/core/network/connectivity_service.dart';
import 'package:flutter/material.dart';

/// Strip shown while the device has no network, so a screen that cannot
/// load or send explains itself instead of just failing.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = getIt<ConnectivityService>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<bool>(
      stream: connectivity.onConnectivityChanged,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;

        return AnimatedSize(
          duration: AppDurations.medium,
          curve: Curves.easeOutCubic,
          child: isOnline
              ? const SizedBox(width: double.infinity)
              : Container(
                  width: double.infinity,
                  color: scheme.errorContainer,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimens.spaceXs,
                    horizontal: AppDimens.spaceM,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: AppDimens.iconS,
                        color: scheme.onErrorContainer,
                      ),
                      const SizedBox(width: AppDimens.spaceS),
                      Text(
                        l10n.errorNetworkTitle,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
