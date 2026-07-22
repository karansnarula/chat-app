import 'package:chat_app/features/friend_requests/data/models/friend_request_dto.dart';
import 'package:chat_app/features/friend_requests/data/models/respond_request_dto.dart';
import 'package:chat_app/features/friend_requests/data/models/send_request_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'friends_api.g.dart';

@RestApi()
abstract class FriendsApi {
  factory FriendsApi(Dio dio) = _FriendsApi;

  @GET('/friends/requests')
  Future<List<FriendRequestDto>> getPendingRequests();

  @POST('/friends/request')
  Future<void> sendRequest(@Body() SendRequestDto body);

  @POST('/friends/request/{id}/respond')
  Future<void> respondToRequest(
    @Path('id') String requestId,
    @Body() RespondRequestDto body,
  );
}
