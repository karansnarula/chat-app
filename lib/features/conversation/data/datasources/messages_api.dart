import 'package:chat_app/features/conversation/data/models/message_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'messages_api.g.dart';

@RestApi()
abstract class MessagesApi {
  factory MessagesApi(Dio dio) = _MessagesApi;

  @GET('/messages/{conversationId}')
  Future<MessagePageDto> getMessages(
    @Path('conversationId') String conversationId,
    @Query('cursor') String? cursor,
    @Query('limit') int limit,
  );

  @POST('/messages/{conversationId}')
  Future<MessageDto> sendMessage(
    @Path('conversationId') String conversationId,
    @Body() SendMessageBodyDto body,
  );

  @PATCH('/messages/{conversationId}/read')
  Future<void> markAsRead(@Path('conversationId') String conversationId);
}
