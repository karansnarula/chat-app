import 'package:chat_app/core/constants/api_constants.dart';
import 'package:chat_app/core/error/api_guard.dart';
import 'package:chat_app/core/error/app_exception.dart';
import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/core/network/socket_service.dart';
import 'package:chat_app/core/storage/token_storage.dart';
import 'package:chat_app/features/conversation/data/datasources/messages_api.dart';
import 'package:chat_app/features/conversation/data/models/message_dto.dart';
import 'package:chat_app/features/conversation/domain/entities/message.dart';
import 'package:chat_app/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ConversationRepository)
class ConversationRepositoryImpl implements ConversationRepository {
  const ConversationRepositoryImpl(
    this._api,
    this._tokenStorage,
    this._socketService,
  );

  final MessagesApi _api;
  final TokenStorage _tokenStorage;
  final SocketService _socketService;

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

  /// Sent over the socket rather than REST: the backend only notifies the
  /// recipient from its gateway handler, so a message stored over REST
  /// would never reach them.
  @override
  Future<Result<Message>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final json = await _socketService.sendMessage(
        conversationId: conversationId,
        content: content,
      );
      return Success(MessageDto.fromJson(json).toEntity());
    } on SocketUnavailableException {
      return const Failure(NetworkException());
    } on Exception catch (error) {
      return Failure(UnknownException(error.toString()));
    }
  }

  @override
  Future<Result<void>> markAsRead(String conversationId) =>
      guard(() => _api.markAsRead(conversationId));

  @override
  Future<String?> currentUserId() => _tokenStorage.readUserId();

  @override
  Stream<Message> incomingMessages(String conversationId) => _socketService
      .messages
      .where((message) => message.conversationId == conversationId)
      .map(
        (message) => Message(
          id: message.id,
          content: message.content,
          senderId: message.senderId,
          createdAt: message.createdAt,
          status: MessageStatus.sent,
        ),
      );

  @override
  Stream<void> readReceipts(String conversationId) => _socketService
      .readReceipts
      .where((receipt) => receipt.conversationId == conversationId);

  @override
  Stream<void> get reconnections => _socketService.reconnections;
}
