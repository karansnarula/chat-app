import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/friend_requests/domain/entities/friend_request.dart';

abstract interface class FriendRequestsRepository {
  Future<Result<List<FriendRequest>>> getPendingRequests();

  Future<Result<void>> sendRequest(String email);

  Future<Result<void>> respondToRequest({
    required String requestId,
    required RequestResponse response,
  });
}
