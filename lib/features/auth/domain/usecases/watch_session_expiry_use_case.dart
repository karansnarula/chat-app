import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class WatchSessionExpiryUseCase {
  const WatchSessionExpiryUseCase(this._repository);

  final AuthRepository _repository;

  Stream<void> call() => _repository.onSessionExpired;
}
