import 'package:chat_app/core/error/api_guard.dart';
import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/friend_requests/data/datasources/friends_api.dart';
import 'package:chat_app/features/friend_requests/data/models/respond_request_dto.dart';
import 'package:chat_app/features/friend_requests/data/models/send_request_dto.dart';
import 'package:chat_app/features/friend_requests/domain/entities/friend_request.dart';
import 'package:chat_app/features/friend_requests/domain/repositories/friend_requests_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: FriendRequestsRepository)
class FriendRequestsRepositoryImpl implements FriendRequestsRepository {
  const FriendRequestsRepositoryImpl(this._api);

  final FriendsApi _api;

  @override
  Future<Result<List<FriendRequest>>> getPendingRequests() async {
    final result = await guard(_api.getPendingRequests);
    return switch (result) {
      Success(:final value) => Success(
        value.map((dto) => dto.toEntity()).toList(),
      ),
      Failure(:final exception) => Failure(exception),
    };
  }

  @override
  Future<Result<void>> sendRequest(String email) =>
      guard(() => _api.sendRequest(SendRequestDto(email: email)));

  @override
  Future<Result<void>> respondToRequest({
    required String requestId,
    required RequestResponse response,
  }) => guard(
    () => _api.respondToRequest(
      requestId,
      RespondRequestDto(action: response.name),
    ),
  );
}
