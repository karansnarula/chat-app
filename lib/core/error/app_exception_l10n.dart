import 'package:chat_app/core/error/app_exception.dart';
import 'package:chat_app/core/l10n/generated/app_localizations.dart';

extension AppExceptionL10n on AppException {
  /// User-facing copy: localized for transport failures, server-provided
  /// for business errors (e.g. "Invalid credentials").
  String localizedMessage(AppLocalizations l10n) => switch (this) {
        NetworkException() => l10n.errorNetworkMessage,
        UnauthorizedException(:final message) => message,
        ServerException(:final message) => message,
        UnknownException() => l10n.errorGenericMessage,
      };
}
