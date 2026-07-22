import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/conversation/domain/entities/message.dart';

abstract interface class ConversationRepository {
  /// Newest-first page; [cursor] fetches the page older than that message.
  Future<Result<MessagePage>> getMessages({
    required String conversationId,
    String? cursor,
  });

  Future<Result<Message>> sendMessage({
    required String conversationId,
    required String content,
  });

  Future<Result<void>> markAsRead(String conversationId);

  /// Id of the signed-in user, used to align and attribute messages.
  Future<String?> currentUserId();
}
