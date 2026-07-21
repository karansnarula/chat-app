import 'package:bloc_test/bloc_test.dart';
import 'package:chat_app/core/error/app_exception.dart';
import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/chats/domain/entities/conversation.dart';
import 'package:chat_app/features/chats/domain/usecases/get_conversations_use_case.dart';
import 'package:chat_app/features/chats/presentation/bloc/chats_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetConversationsUseCase extends Mock
    implements GetConversationsUseCase {}

void main() {
  final conversations = [
    Conversation(
      id: 'c1',
      otherUser: const ConversationUser(
        id: 'u2',
        displayName: 'Alice',
        email: 'alice@test.com',
      ),
      unreadCount: 2,
      lastMessage: LastMessage(
        id: 'm1',
        content: 'Hello!',
        senderId: 'u2',
        createdAt: DateTime(2026, 7, 22, 10),
      ),
    ),
  ];

  late MockGetConversationsUseCase getConversations;

  setUp(() => getConversations = MockGetConversationsUseCase());

  ChatsBloc buildBloc() => ChatsBloc(getConversations);

  blocTest<ChatsBloc, ChatsState>(
    'emits loading then success with conversations',
    build: buildBloc,
    setUp: () => when(getConversations.call)
        .thenAnswer((_) async => Success(conversations)),
    act: (bloc) => bloc.add(const ChatsRequested()),
    expect: () => [
      const ChatsState.loading(),
      ChatsState.success(conversations),
    ],
  );

  blocTest<ChatsBloc, ChatsState>(
    'emits loading then failure when the request fails',
    build: buildBloc,
    setUp: () => when(getConversations.call)
        .thenAnswer((_) async => const Failure(NetworkException())),
    act: (bloc) => bloc.add(const ChatsRequested()),
    expect: () => [
      const ChatsState.loading(),
      const ChatsState.failure(NetworkException()),
    ],
  );

  blocTest<ChatsBloc, ChatsState>(
    'refresh does not emit loading, keeping the list on screen',
    build: buildBloc,
    seed: () => const ChatsState.success([]),
    setUp: () => when(getConversations.call)
        .thenAnswer((_) async => Success(conversations)),
    act: (bloc) => bloc.add(const ChatsRefreshed()),
    expect: () => [ChatsState.success(conversations)],
  );

  test('isEmpty is only true for a successful empty result', () {
    expect(const ChatsState.success([]).isEmpty, isTrue);
    expect(ChatsState.success(conversations).isEmpty, isFalse);
    expect(const ChatsState.loading().isEmpty, isFalse);
  });
}
