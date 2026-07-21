import 'package:chat_app/features/chats/data/models/conversation_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'chats_api.g.dart';

@RestApi()
// ignore: one_member_abstracts — grows as conversation endpoints are added
abstract class ChatsApi {
  factory ChatsApi(Dio dio) = _ChatsApi;

  @GET('/conversations')
  Future<List<ConversationDto>> getConversations();
}
