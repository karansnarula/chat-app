import 'package:bloc_test/bloc_test.dart';
import 'package:chat_app/core/di/injection.dart';
import 'package:chat_app/core/error/app_exception.dart';
import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/core/widgets/app_state_view.dart';
import 'package:chat_app/features/chats/domain/entities/conversation.dart';
import 'package:chat_app/features/chats/presentation/bloc/chats_bloc.dart';
import 'package:chat_app/features/chats/presentation/screens/chats_screen.dart';
import 'package:chat_app/features/chats/presentation/widgets/conversation_list_skeleton.dart';
import 'package:chat_app/features/chats/presentation/widgets/conversation_tile.dart';
import 'package:chat_app/features/friend_requests/presentation/bloc/friend_requests_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatsBloc extends MockBloc<ChatsEvent, ChatsState>
    implements ChatsBloc {}

class MockFriendRequestsBloc
    extends MockBloc<FriendRequestsEvent, FriendRequestsState>
    implements FriendRequestsBloc {}

void main() {
  late MockChatsBloc chatsBloc;
  late MockFriendRequestsBloc friendRequestsBloc;

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
        content: 'See you soon',
        senderId: 'u2',
        createdAt: DateTime.now(),
      ),
    ),
  ];

  setUp(() {
    chatsBloc = MockChatsBloc();
    friendRequestsBloc = MockFriendRequestsBloc();

    whenListen(
      friendRequestsBloc,
      const Stream<FriendRequestsState>.empty(),
      initialState: const FriendRequestsState(),
    );

    // The screen resolves its bloc from the service locator.
    getIt.registerFactory<ChatsBloc>(() => chatsBloc);
  });

  tearDown(getIt.reset);

  Widget wrap() => MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<FriendRequestsBloc>.value(
          value: friendRequestsBloc,
          child: const ChatsScreen(),
        ),
      );

  testWidgets('shows the skeleton while loading', (tester) async {
    whenListen(
      chatsBloc,
      const Stream<ChatsState>.empty(),
      initialState: const ChatsState.loading(),
    );

    await tester.pumpWidget(wrap());

    expect(find.byType(ConversationListSkeleton), findsOneWidget);
  });

  testWidgets('shows the empty state when there are no conversations',
      (tester) async {
    whenListen(
      chatsBloc,
      const Stream<ChatsState>.empty(),
      initialState: const ChatsState.success([]),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.byType(AppStateView), findsOneWidget);
    expect(find.text('No chats yet'), findsOneWidget);
  });

  testWidgets('renders conversation tiles when loaded', (tester) async {
    whenListen(
      chatsBloc,
      const Stream<ChatsState>.empty(),
      initialState: ChatsState.success(conversations),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.byType(ConversationTile), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('See you soon'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('shows a retry action on failure', (tester) async {
    whenListen(
      chatsBloc,
      const Stream<ChatsState>.empty(),
      initialState: const ChatsState.failure(NetworkException()),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.byType(AppStateRetryButton), findsOneWidget);

    await tester.tap(find.byType(AppStateRetryButton));
    verify(() => chatsBloc.add(const ChatsRequested())).called(greaterThan(0));
  });
}
