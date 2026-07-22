import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/core/network/socket_service.dart';
import 'package:chat_app/core/notifications/notification_service.dart';
import 'package:chat_app/features/auth/domain/entities/auth_user.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class RegisterUseCase {
  const RegisterUseCase(
    this._repository,
    this._socketService,
    this._notificationService,
  );

  final AuthRepository _repository;
  final SocketService _socketService;
  final NotificationService _notificationService;

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
    if (result is Success<AuthUser>) {
      await _socketService.connect();
      await _notificationService.registerToken();
    }
    return result;
  }
}
