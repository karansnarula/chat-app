import 'package:chat_app/core/network/socket_service.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class LogoutUseCase {
  const LogoutUseCase(this._repository, this._socketService);

  final AuthRepository _repository;
  final SocketService _socketService;

  Future<void> call() async {
    _socketService.disconnect();
    await _repository.logout();
  }
}
