import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class RegisterPushTokenUseCase {
  const RegisterPushTokenUseCase(this._repository);

  final NotificationsRepository _repository;

  Future<Result<void>> call(String token) =>
      _repository.registerPushToken(token);
}
