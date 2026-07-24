import 'package:chat_app/core/error/app_exception.dart';
import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/core/network/conversation_read_notifier.dart';
import 'package:chat_app/core/network/socket_service.dart';
import 'package:chat_app/features/chats/data/datasources/chats_api.dart';
import 'package:chat_app/features/chats/data/models/conversation_dto.dart';
import 'package:chat_app/features/chats/data/repositories/chats_repository_impl.dart';
import 'package:chat_app/features/chats/domain/entities/conversation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatsApi extends Mock implements ChatsApi {}

class MockSocketService extends Mock implements SocketService {}

class FakeReadNotifier extends Fake implements ConversationReadNotifier {
  @override
  Stream<void> get onRead => const Stream.empty();
}

void main() {
  late MockChatsApi api;
  late MockSocketService socketService;
  late ChatsRepositoryImpl repository;

  setUp(() {
    api = MockChatsApi();
    socketService = MockSocketService();
    repository = ChatsRepositoryImpl(api, socketService, FakeReadNotifier());
  });

  test('maps DTOs to entities on success', () async {
    when(api.getConversations).thenAnswer(
      (_) async => [
        ConversationDto(
          id: 'c1',
          otherUser: const ConversationUserDto(
            id: 'u2',
            displayName: 'Alice',
            email: 'alice@test.com',
          ),
          unreadCount: 3,
          lastMessage: LastMessageDto(
            id: 'm1',
            content: 'Hello!',
            senderId: 'u2',
            createdAt: DateTime(2026, 7, 22, 10),
          ),
        ),
      ],
    );

    final result = await repository.getConversations();

    final conversations = (result as Success<List<Conversation>>).value;
    expect(conversations, hasLength(1));
    expect(conversations.single.otherUser.displayName, 'Alice');
    expect(conversations.single.unreadCount, 3);
    expect(conversations.single.lastMessage?.content, 'Hello!');
  });

  test('returns Failure when the request throws', () async {
    when(api.getConversations).thenThrow(
      DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionError,
      ),
    );

    final result = await repository.getConversations();

    expect((result as Failure).exception, isA<NetworkException>());
  });
}
