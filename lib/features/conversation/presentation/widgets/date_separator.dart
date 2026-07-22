import 'package:chat_app/core/constants/app_dimens.dart';
import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSeparator extends StatelessWidget {
  const DateSeparator({required this.date, super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppDimens.spaceM),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spaceM,
          vertical: AppDimens.spaceXs,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        ),
        child: Text(
          _label(l10n),
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  String _label(AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final daysApart = today.difference(day).inDays;

    if (daysApart == 0) return l10n.today;
    if (daysApart == 1) return l10n.yesterday;
    if (daysApart < 7) return DateFormat.EEEE(l10n.localeName).format(date);
    return DateFormat.yMMMd(l10n.localeName).format(date);
  }
}
