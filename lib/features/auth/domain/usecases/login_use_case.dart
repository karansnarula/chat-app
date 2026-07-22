import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/core/network/socket_service.dart';
import 'package:chat_app/features/auth/domain/entities/auth_user.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

/// Authenticates, then opens the realtime connection. Will also register
/// the FCM token once push notifications land.
@injectable
class LoginUseCase {
  const LoginUseCase(this._repository, this._socketService);

  final AuthRepository _repository;
  final SocketService _socketService;

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
  }) async {
    final result = await _repository.login(email: email, password: password);
    if (result is Success<AuthUser>) await _socketService.connect();
    return result;
  }
}
