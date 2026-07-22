import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/friend_requests/domain/entities/friend_request.dart';
import 'package:chat_app/features/friend_requests/domain/repositories/friend_requests_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetPendingRequestsUseCase {
  const GetPendingRequestsUseCase(this._repository);

  final FriendRequestsRepository _repository;

  Future<Result<List<FriendRequest>>> call() =>
      _repository.getPendingRequests();
}
