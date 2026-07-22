import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/chats/domain/entities/conversation.dart';

abstract interface class ChatsRepository {
  Future<Result<List<Conversation>>> getConversations();

  /// Fires whenever the list may have changed: a message arrived, or the
  /// realtime connection came back after a gap.
  Stream<void> get conversationsInvalidated;
}
