import 'package:chat_app/core/constants/api_constants.dart';
import 'package:chat_app/core/error/api_guard.dart';
import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/core/storage/token_storage.dart';
import 'package:chat_app/features/conversation/data/datasources/messages_api.dart';
import 'package:chat_app/features/conversation/data/models/message_dto.dart';
import 'package:chat_app/features/conversation/domain/entities/message.dart';
import 'package:chat_app/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ConversationRepository)
class ConversationRepositoryImpl implements ConversationRepository {
  const ConversationRepositoryImpl(this._api, this._tokenStorage);

  final MessagesApi _api;
  final TokenStorage _tokenStorage;

  @override
  Future<Result<MessagePage>> getMessages({
    required String conversationId,
    String? cursor,
  }) async {
    final result = await guard(
      () => _api.getMessages(
        conversationId,
        cursor,
        ApiConstants.messagePageSize,
      ),
    );
    return switch (result) {
      Success(:final value) => Success(value.toEntity()),
      Failure(:final exception) => Failure(exception),
    };
  }

  @override
  Future<Result<Message>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final result = await guard(
      () => _api.sendMessage(
        conversationId,
        SendMessageBodyDto(content: content),
      ),
    );
    return switch (result) {
      Success(:final value) => Success(value.toEntity()),
      Failure(:final exception) => Failure(exception),
    };
  }

  @override
  Future<Result<void>> markAsRead(String conversationId) =>
      guard(() => _api.markAsRead(conversationId));

  @override
  Future<String?> currentUserId() => _tokenStorage.readUserId();
}
