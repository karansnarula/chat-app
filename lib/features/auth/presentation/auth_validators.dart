import 'package:chat_app/core/l10n/generated/app_localizations.dart';

abstract final class AuthValidators {
  static const int minPasswordLength = 8;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value, AppLocalizations l10n) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return l10n.emailRequired;
    return _emailPattern.hasMatch(email) ? null : l10n.emailInvalid;
  }

  static String? password(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.passwordRequired;
    if (value.length < minPasswordLength) return l10n.passwordTooShort;
    return null;
  }

  static String? displayName(String? value, AppLocalizations l10n) =>
      (value == null || value.trim().isEmpty)
          ? l10n.displayNameRequired
          : null;
}
