import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class MarkAsReadUseCase {
  const MarkAsReadUseCase(this._repository);

  final ConversationRepository _repository;

  Future<Result<void>> call(String conversationId) =>
      _repository.markAsRead(conversationId);
}
