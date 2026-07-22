import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/conversation/domain/entities/message.dart';
import 'package:chat_app/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetMessagesUseCase {
  const GetMessagesUseCase(this._repository);

  final ConversationRepository _repository;

  Future<Result<MessagePage>> call({
    required String conversationId,
    String? cursor,
  }) =>
      _repository.getMessages(conversationId: conversationId, cursor: cursor);
}
