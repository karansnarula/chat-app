import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/auth/domain/entities/auth_user.dart';

abstract interface class AuthRepository {
  Future<Result<AuthUser>> login({
    required String email,
    required String password,
  });

  Future<Result<AuthUser>> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> logout();

  Future<bool> hasSession();

  /// Fires when a token refresh fails and the user must re-authenticate.
  Stream<void> get onSessionExpired;
}
