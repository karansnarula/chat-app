import 'package:chat_app/core/constants/app_dimens.dart';
import 'package:chat_app/core/constants/app_durations.dart';
import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Shared empty/error state: soft icon badge, title, message, and an
/// optional retry action. Fades and slides in for a polished feel.
class AppStateView extends StatelessWidget {
  const AppStateView({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: AppDurations.medium,
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, AppDimens.spaceM * (1 - value)),
            child: child,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spaceXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppDimens.stateViewIconCircle,
                height: AppDimens.stateViewIconCircle,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: AppDimens.iconXl,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: AppDimens.spaceL),
              Text(
                title,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.spaceS),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppDimens.spaceL),
                AppStateRetryButton(onRetry: onRetry!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppStateRetryButton extends StatelessWidget {
  const AppStateRetryButton({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
      label: Text(AppLocalizations.of(context).retry),
    );
  }
}
