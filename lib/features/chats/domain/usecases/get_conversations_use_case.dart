import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/chats/domain/entities/conversation.dart';
import 'package:chat_app/features/chats/domain/repositories/chats_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetConversationsUseCase {
  const GetConversationsUseCase(this._repository);

  final ChatsRepository _repository;

  Future<Result<List<Conversation>>> call() => _repository.getConversations();
}
