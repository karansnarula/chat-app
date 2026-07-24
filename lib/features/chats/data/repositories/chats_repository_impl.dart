import 'package:async/async.dart' show StreamGroup;
import 'package:chat_app/core/error/api_guard.dart';
import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/core/network/conversation_read_notifier.dart';
import 'package:chat_app/core/network/socket_service.dart';
import 'package:chat_app/features/chats/data/datasources/chats_api.dart';
import 'package:chat_app/features/chats/domain/entities/conversation.dart';
import 'package:chat_app/features/chats/domain/repositories/chats_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ChatsRepository)
class ChatsRepositoryImpl implements ChatsRepository {
  const ChatsRepositoryImpl(this._api, this._socketService, this._readNotifier);

  final ChatsApi _api;
  final SocketService _socketService;
  final ConversationReadNotifier _readNotifier;

  @override
  Future<Result<List<Conversation>>> getConversations() async {
    final result = await guard(_api.getConversations);
    return switch (result) {
      Success(:final value) =>
        Success(value.map((dto) => dto.toEntity()).toList()),
      Failure(:final exception) => Failure(exception),
    };
  }

  @override
  Stream<void> get conversationsInvalidated => StreamGroup.merge([
        _socketService.messages,
        _socketService.readReceipts,
        _socketService.reconnections,
        _readNotifier.onRead,
      ]);
}
