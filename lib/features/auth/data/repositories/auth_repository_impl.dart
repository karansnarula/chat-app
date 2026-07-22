import 'package:chat_app/core/error/api_guard.dart';
import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/core/network/session_manager.dart';
import 'package:chat_app/core/storage/token_storage.dart';
import 'package:chat_app/features/auth/data/datasources/auth_api.dart';
import 'package:chat_app/features/auth/data/models/auth_response_dto.dart';
import 'package:chat_app/features/auth/data/models/login_request_dto.dart';
import 'package:chat_app/features/auth/data/models/register_request_dto.dart';
import 'package:chat_app/features/auth/domain/entities/auth_user.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._api, this._tokenStorage, this._sessionManager);

  final AuthApi _api;
  final TokenStorage _tokenStorage;
  final SessionManager _sessionManager;

  @override
  Future<Result<AuthUser>> login({
    required String email,
    required String password,
  }) =>
      _authenticate(
        () => _api.login(LoginRequestDto(email: email, password: password)),
      );

  @override
  Future<Result<AuthUser>> register({
    required String email,
    required String password,
    required String displayName,
  }) =>
      _authenticate(
        () => _api.register(
          RegisterRequestDto(
            email: email,
            password: password,
            displayName: displayName,
          ),
        ),
      );

  Future<Result<AuthUser>> _authenticate(
    Future<AuthResponseDto> Function() request,
  ) async {
    switch (await guard(request)) {
      case Success(:final value):
        await _tokenStorage.saveTokens(
          accessToken: value.accessToken,
          refreshToken: value.refreshToken,
        );
        await _tokenStorage.saveUserId(value.user.id);
        return Success(value.user.toEntity());
      case Failure(:final exception):
        return Failure(exception);
    }
  }

  @override
  Future<void> logout() async {
    // Best effort: local session must end even if the server call fails.
    try {
      await _api.logout();
    } on Exception {
      // Ignored — token revocation is not implemented server-side.
    } finally {
      await _tokenStorage.clear();
    }
  }

  @override
  Future<bool> hasSession() => _tokenStorage.hasTokens;

  @override
  Stream<void> get onSessionExpired => _sessionManager.onSessionExpired;
}
