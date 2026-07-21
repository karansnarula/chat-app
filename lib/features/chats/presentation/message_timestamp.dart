import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

/// Chat-list timestamp: clock time today, "Yesterday", weekday within the
/// last week, and a short date beyond that.
String formatMessageTimestamp(DateTime timestamp, AppLocalizations l10n) {
  final local = timestamp.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final messageDay = DateTime(local.year, local.month, local.day);
  final daysApart = today.difference(messageDay).inDays;

  if (daysApart == 0) return DateFormat.jm(l10n.localeName).format(local);
  if (daysApart == 1) return l10n.yesterday;
  if (daysApart < 7) return DateFormat.E(l10n.localeName).format(local);
  return DateFormat.yMd(l10n.localeName).format(local);
}
