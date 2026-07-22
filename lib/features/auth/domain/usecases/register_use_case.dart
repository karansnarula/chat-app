import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/core/network/socket_service.dart';
import 'package:chat_app/features/auth/domain/entities/auth_user.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class RegisterUseCase {
  const RegisterUseCase(this._repository, this._socketService);

  final AuthRepository _repository;
  final SocketService _socketService;

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final result = await _repository.register(
      email: email,
      password: password,
      displayName: displayName,
    );
    if (result is Success<AuthUser>) await _socketService.connect();
    return result;
  }
}
