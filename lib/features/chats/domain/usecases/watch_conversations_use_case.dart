import 'package:chat_app/features/chats/domain/repositories/chats_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class WatchConversationsUseCase {
  const WatchConversationsUseCase(this._repository);

  final ChatsRepository _repository;

  Stream<void> call() => _repository.conversationsInvalidated;
}
