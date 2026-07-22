import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/conversation/domain/entities/message.dart';
import 'package:chat_app/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SendMessageUseCase {
  const SendMessageUseCase(this._repository);

  final ConversationRepository _repository;

  Future<Result<Message>> call({
    required String conversationId,
    required String content,
  }) =>
      _repository.sendMessage(
        conversationId: conversationId,
        content: content,
      );
}
