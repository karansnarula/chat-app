import 'package:chat_app/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetCurrentUserIdUseCase {
  const GetCurrentUserIdUseCase(this._repository);

  final ConversationRepository _repository;

  Future<String?> call() => _repository.currentUserId();
}
