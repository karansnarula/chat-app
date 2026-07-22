import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:chat_app/core/error/app_exception.dart';
import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/conversation/domain/entities/message.dart';
import 'package:chat_app/features/conversation/domain/usecases/get_current_user_id_use_case.dart';
import 'package:chat_app/features/conversation/domain/usecases/get_messages_use_case.dart';
import 'package:chat_app/features/conversation/domain/usecases/mark_as_read_use_case.dart';
import 'package:chat_app/features/conversation/domain/usecases/send_message_use_case.dart';
import 'package:chat_app/features/conversation/domain/usecases/watch_conversation_use_case.dart';
import 'package:chat_app/features/conversation/presentation/bloc/conversation_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetMessages extends Mock implements GetMessagesUseCase {}

class MockSendMessage extends Mock implements SendMessageUseCase {}

class MockMarkAsRead extends Mock implements MarkAsReadUseCase {}

class MockGetCurrentUserId extends Mock implements GetCurrentUserIdUseCase {}

class MockWatchIncomingMessages extends Mock
    implements WatchIncomingMessagesUseCase {}

class MockWatchReadReceipts extends Mock
    implements WatchReadReceiptsUseCase {}

class MockWatchReconnections extends Mock
    implements WatchReconnectionsUseCase {}

void main() {
  const conversationId = 'c1';
  const myId = 'u1';

  final older = Message(
    id: 'm1',
    content: 'Older',
    senderId: 'u2',
    createdAt: DateTime(2026, 7, 21, 10),
    status: MessageStatus.read,
  );
  final newer = Message(
    id: 'm2',
    content: 'Newer',
    senderId: myId,
    createdAt: DateTime(2026, 7, 22, 10),
    status: MessageStatus.sent,
  );

  late MockGetMessages getMessages;
  late MockSendMessage sendMessage;
  late MockMarkAsRead markAsRead;
  late MockGetCurrentUserId getCurrentUserId;
  late MockWatchIncomingMessages watchMessages;
  late MockWatchReadReceipts watchReadReceipts;
  late MockWatchReconnections watchReconnections;
  late StreamController<Message> incoming;
  late StreamController<void> reads;
  late StreamController<void> reconnects;

  setUp(() {
    getMessages = MockGetMessages();
    sendMessage = MockSendMessage();
    markAsRead = MockMarkAsRead();
    getCurrentUserId = MockGetCurrentUserId();
    watchMessages = MockWatchIncomingMessages();
    watchReadReceipts = MockWatchReadReceipts();
    watchReconnections = MockWatchReconnections();

    incoming = StreamController<Message>.broadcast();
    reads = StreamController<void>.broadcast();
    reconnects = StreamController<void>.broadcast();

    when(getCurrentUserId.call).thenAnswer((_) async => myId);
    when(() => markAsRead(any())).thenAnswer((_) async => const Success(null));
    when(() => watchMessages(any())).thenAnswer((_) => incoming.stream);
    when(() => watchReadReceipts(any())).thenAnswer((_) => reads.stream);
    when(watchReconnections.call).thenAnswer((_) => reconnects.stream);
  });

  tearDown(() async {
    await incoming.close();
    await reads.close();
    await reconnects.close();
  });

  ConversationBloc buildBloc() => ConversationBloc(
        conversationId,
        getMessages,
        sendMessage,
        markAsRead,
        getCurrentUserId,
        watchMessages,
        watchReadReceipts,
        watchReconnections,
      );

  void stubFirstPage({String? nextCursor}) {
    when(() => getMessages(conversationId: conversationId)).thenAnswer(
      (_) async => Success(
        MessagePage(messages: [newer, older], nextCursor: nextCursor),
      ),
    );
  }

  group('opening', () {
    blocTest<ConversationBloc, ConversationState>(
      'loads the first page and marks the thread read',
      build: buildBloc,
      setUp: stubFirstPage,
      act: (bloc) => bloc.add(const ConversationOpened()),
      verify: (bloc) {
        expect(bloc.state.status, ConversationStatus.success);
        expect(bloc.state.messages, [newer, older]);
        expect(bloc.state.currentUserId, myId);
        verify(() => markAsRead(conversationId)).called(1);
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits failure and does not mark read when loading fails',
      build: buildBloc,
      setUp: () => when(() => getMessages(conversationId: conversationId))
          .thenAnswer((_) async => const Failure(NetworkException())),
      act: (bloc) => bloc.add(const ConversationOpened()),
      verify: (bloc) {
        expect(bloc.state.status, ConversationStatus.failure);
        verifyNever(() => markAsRead(any()));
      },
    );
  });

  group('pagination', () {
    blocTest<ConversationBloc, ConversationState>(
      'appends the older page and clears the cursor when exhausted',
      build: buildBloc,
      seed: () => ConversationState(
        status: ConversationStatus.success,
        messages: [newer],
        currentUserId: myId,
        nextCursor: 'cursor-1',
      ),
      setUp: () => when(
        () => getMessages(
          conversationId: conversationId,
          cursor: 'cursor-1',
        ),
      ).thenAnswer(
        (_) async => Success(MessagePage(messages: [older])),
      ),
      act: (bloc) => bloc.add(const ConversationOlderPageRequested()),
      verify: (bloc) {
        expect(bloc.state.messages, [newer, older]);
        expect(bloc.state.hasMore, isFalse);
        expect(bloc.state.isLoadingOlder, isFalse);
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'ignores the request when there are no more pages',
      build: buildBloc,
      seed: () => ConversationState(
        status: ConversationStatus.success,
        messages: [newer],
        currentUserId: myId,
      ),
      act: (bloc) => bloc.add(const ConversationOlderPageRequested()),
      expect: () => <ConversationState>[],
    );

    blocTest<ConversationBloc, ConversationState>(
      'keeps loaded messages when fetching an older page fails',
      build: buildBloc,
      seed: () => ConversationState(
        status: ConversationStatus.success,
        messages: [newer],
        currentUserId: myId,
        nextCursor: 'cursor-1',
      ),
      setUp: () => when(
        () => getMessages(
          conversationId: conversationId,
          cursor: 'cursor-1',
        ),
      ).thenAnswer((_) async => const Failure(NetworkException())),
      act: (bloc) => bloc.add(const ConversationOlderPageRequested()),
      verify: (bloc) {
        expect(bloc.state.messages, [newer]);
        expect(bloc.state.status, ConversationStatus.success);
        expect(bloc.state.isLoadingOlder, isFalse);
      },
    );
  });

  group('sending', () {
    final sent = Message(
      id: 'server-1',
      content: 'Hello',
      senderId: myId,
      createdAt: DateTime(2026, 7, 22, 11),
      status: MessageStatus.sent,
    );

    blocTest<ConversationBloc, ConversationState>(
      'shows the message immediately then swaps in the server copy',
      build: buildBloc,
      seed: () => const ConversationState(
        status: ConversationStatus.success,
        currentUserId: myId,
      ),
      setUp: () => when(
        () => sendMessage(
          conversationId: conversationId,
          content: 'Hello',
        ),
      ).thenAnswer((_) async => Success(sent)),
      act: (bloc) => bloc.add(const ConversationMessageSent('Hello')),
      verify: (bloc) {
        expect(bloc.state.messages, [sent]);
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'marks the message failed so it can be retried',
      build: buildBloc,
      seed: () => const ConversationState(
        status: ConversationStatus.success,
        currentUserId: myId,
      ),
      setUp: () => when(
        () => sendMessage(
          conversationId: conversationId,
          content: 'Hello',
        ),
      ).thenAnswer((_) async => const Failure(NetworkException())),
      act: (bloc) => bloc.add(const ConversationMessageSent('Hello')),
      verify: (bloc) {
        expect(bloc.state.messages.single.status, MessageStatus.failed);
        expect(bloc.state.messages.single.content, 'Hello');
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'ignores blank messages',
      build: buildBloc,
      seed: () => const ConversationState(
        status: ConversationStatus.success,
        currentUserId: myId,
      ),
      act: (bloc) => bloc.add(const ConversationMessageSent('   ')),
      expect: () => <ConversationState>[],
    );

    blocTest<ConversationBloc, ConversationState>(
      'retrying a failed message replaces it with the server copy',
      build: buildBloc,
      seed: () => ConversationState(
        status: ConversationStatus.success,
        currentUserId: myId,
        messages: [
          Message(
            id: '${ConversationBloc.localIdPrefix}1',
            content: 'Hello',
            senderId: myId,
            createdAt: DateTime(2026, 7, 22, 11),
            status: MessageStatus.failed,
          ),
        ],
      ),
      setUp: () => when(
        () => sendMessage(
          conversationId: conversationId,
          content: 'Hello',
        ),
      ).thenAnswer((_) async => Success(sent)),
      act: (bloc) => bloc.add(
        const ConversationMessageRetried(
          '${ConversationBloc.localIdPrefix}1',
        ),
      ),
      verify: (bloc) => expect(bloc.state.messages, [sent]),
    );
  });

  group('realtime', () {
    final pushed = Message(
      id: 'pushed-1',
      content: 'Live message',
      senderId: 'u2',
      createdAt: DateTime(2026, 7, 22, 12),
      status: MessageStatus.sent,
    );

    blocTest<ConversationBloc, ConversationState>(
      'prepends a pushed message and marks the thread read',
      build: buildBloc,
      seed: () => ConversationState(
        status: ConversationStatus.success,
        currentUserId: myId,
        messages: [newer],
      ),
      act: (_) => incoming.add(pushed),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.messages, [pushed, newer]);
        verify(() => markAsRead(conversationId)).called(1);
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'ignores a pushed message it already has',
      build: buildBloc,
      seed: () => ConversationState(
        status: ConversationStatus.success,
        currentUserId: myId,
        messages: [newer],
      ),
      act: (_) => incoming.add(newer),
      wait: const Duration(milliseconds: 50),
      expect: () => <ConversationState>[],
    );

    blocTest<ConversationBloc, ConversationState>(
      'flips my delivered messages to read when the other side reads',
      build: buildBloc,
      seed: () => ConversationState(
        status: ConversationStatus.success,
        currentUserId: myId,
        messages: [newer, older],
      ),
      act: (_) => reads.add(null),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        // Mine flips to read; theirs is untouched.
        expect(bloc.state.messages.first.status, MessageStatus.read);
        expect(bloc.state.messages.last, older);
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'pulls in messages missed while the connection was down',
      build: buildBloc,
      seed: () => ConversationState(
        status: ConversationStatus.success,
        currentUserId: myId,
        messages: [older],
      ),
      setUp: () =>
          when(() => getMessages(conversationId: conversationId)).thenAnswer(
        (_) async => Success(MessagePage(messages: [newer, older])),
      ),
      act: (_) => reconnects.add(null),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) => expect(bloc.state.messages, [newer, older]),
    );
  });

  test('isMine compares the sender against the signed-in user', () {
    const state = ConversationState(currentUserId: myId);

    expect(state.isMine(newer), isTrue);
    expect(state.isMine(older), isFalse);
  });
}
