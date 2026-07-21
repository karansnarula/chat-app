import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/chats/domain/entities/conversation.dart';

// ignore: one_member_abstracts — grows as conversation endpoints are added
abstract interface class ChatsRepository {
  Future<Result<List<Conversation>>> getConversations();
}
