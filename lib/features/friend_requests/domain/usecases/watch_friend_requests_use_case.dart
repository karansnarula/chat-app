import 'package:chat_app/features/friend_requests/domain/repositories/friend_requests_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class WatchFriendRequestsUseCase {
  const WatchFriendRequestsUseCase(this._repository);

  final FriendRequestsRepository _repository;

  Stream<void> call() => _repository.requestsInvalidated;
}
