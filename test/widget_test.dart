import 'package:bloc_test/bloc_test.dart';
import 'package:chat_app/core/di/injection.dart';
import 'package:chat_app/core/notifications/notification_service.dart';
import 'package:chat_app/core/storage/token_storage.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/friend_requests/presentation/bloc/friend_requests_bloc.dart';
import 'package:chat_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class MockFriendRequestsBloc
    extends MockBloc<FriendRequestsEvent, FriendRequestsState>
    implements FriendRequestsBloc {}

class MockNotificationService extends Mock implements NotificationService {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  setUp(() {
    final authBloc = MockAuthBloc();
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthState.unknown(),
    );

    final friendRequestsBloc = MockFriendRequestsBloc();
    whenListen(
      friendRequestsBloc,
      const Stream<FriendRequestsState>.empty(),
      initialState: const FriendRequestsState(),
    );

    final notificationService = MockNotificationService();
    when(() => notificationService.conversationTaps)
        .thenAnswer((_) => const Stream<NotificationTarget>.empty());
    when(notificationService.initialTarget).thenAnswer((_) async => null);

    final tokenStorage = MockTokenStorage();
    when(() => tokenStorage.hasTokens).thenAnswer((_) async => false);

    getIt
      ..registerSingleton<AuthBloc>(authBloc)
      ..registerSingleton<FriendRequestsBloc>(friendRequestsBloc)
      ..registerSingleton<NotificationService>(notificationService)
      ..registerSingleton<TokenStorage>(tokenStorage)
      ..registerSingleton<GoRouter>(
        GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('home'))),
            ),
          ],
        ),
      );
  });

  tearDown(getIt.reset);

  testWidgets('app boots with theme, l10n, and router wired', (tester) async {
    await tester.pumpWidget(const ChatApp());
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
  });
}
