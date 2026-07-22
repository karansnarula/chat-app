/// Non-localizable string constants.
///
/// Everything user-facing and translatable belongs in the l10n `.arb` files,
/// not here.
abstract final class AppStrings {
  static const String appName = 'Chat App';

  /// Android notification channel name. Shown in system settings, so it is
  /// deliberately generic rather than localized per-user.
  static const String messagesChannelName = 'Messages';
}
