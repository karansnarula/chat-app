import 'package:chat_app/core/network/socket_service.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

/// Restores a stored session and, when there is one, reopens the realtime
/// connection.
@injectable
class CheckSessionUseCase {
  const CheckSessionUseCase(this._repository, this._socketService);

  final AuthRepository _repository;
  final SocketService _socketService;

  Future<bool> call() async {
    final hasSession = await _repository.hasSession();
    if (hasSession) await _socketService.connect();
    return hasSession;
  }
}
