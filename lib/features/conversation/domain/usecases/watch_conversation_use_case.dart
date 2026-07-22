import 'package:chat_app/features/conversation/domain/entities/message.dart';
import 'package:chat_app/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class WatchIncomingMessagesUseCase {
  const WatchIncomingMessagesUseCase(this._repository);

  final ConversationRepository _repository;

  Stream<Message> call(String conversationId) =>
      _repository.incomingMessages(conversationId);
}

@injectable
class WatchReadReceiptsUseCase {
  const WatchReadReceiptsUseCase(this._repository);

  final ConversationRepository _repository;

  Stream<void> call(String conversationId) =>
      _repository.readReceipts(conversationId);
}

@injectable
class WatchReconnectionsUseCase {
  const WatchReconnectionsUseCase(this._repository);

  final ConversationRepository _repository;

  Stream<void> call() => _repository.reconnections;
}
