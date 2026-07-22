import 'package:bloc_test/bloc_test.dart';
import 'package:chat_app/core/error/app_exception.dart';
import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/chats/domain/entities/conversation.dart';
import 'package:chat_app/features/chats/domain/usecases/get_conversations_use_case.dart';
import 'package:chat_app/features/chats/domain/usecases/watch_conversations_use_case.dart';
import 'package:chat_app/features/chats/presentation/bloc/chats_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetConversationsUseCase extends Mock
    implements GetConversationsUseCase {}

class MockWatchConversationsUseCase extends Mock
    implements WatchConversationsUseCase {}

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
  late MockWatchConversationsUseCase watchConversations;

  setUp(() {
    getConversations = MockGetConversationsUseCase();
    watchConversations = MockWatchConversationsUseCase();
    when(watchConversations.call).thenAnswer((_) => const Stream.empty());
  });

  ChatsBloc buildBloc() => ChatsBloc(getConversations, watchConversations);

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
    // Refreshes are debounced so socket bursts collapse into one fetch.
    wait: const Duration(milliseconds: 250),
    expect: () => [ChatsState.success(conversations)],
  );

  blocTest<ChatsBloc, ChatsState>(
    'collapses a burst of socket-driven refreshes into one fetch',
    build: buildBloc,
    seed: () => const ChatsState.success([]),
    setUp: () => when(getConversations.call)
        .thenAnswer((_) async => Success(conversations)),
    act: (bloc) => bloc
      ..add(const ChatsRefreshed())
      ..add(const ChatsRefreshed())
      ..add(const ChatsRefreshed()),
    wait: const Duration(milliseconds: 250),
    verify: (_) => verify(getConversations.call).called(1),
  );

  test('isEmpty is only true for a successful empty result', () {
    expect(const ChatsState.success([]).isEmpty, isTrue);
    expect(ChatsState.success(conversations).isEmpty, isFalse);
    expect(const ChatsState.loading().isEmpty, isFalse);
  });
}
