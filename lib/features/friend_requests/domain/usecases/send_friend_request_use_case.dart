import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/friend_requests/domain/repositories/friend_requests_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SendFriendRequestUseCase {
  const SendFriendRequestUseCase(this._repository);

  final FriendRequestsRepository _repository;

  Future<Result<void>> call(String email) => _repository.sendRequest(email);
}
