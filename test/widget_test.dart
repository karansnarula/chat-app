import 'package:bloc_test/bloc_test.dart';
import 'package:chat_app/core/di/injection.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/friend_requests/presentation/bloc/friend_requests_bloc.dart';
import 'package:chat_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class MockFriendRequestsBloc
    extends MockBloc<FriendRequestsEvent, FriendRequestsState>
    implements FriendRequestsBloc {}

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

    getIt
      ..registerSingleton<AuthBloc>(authBloc)
      ..registerSingleton<FriendRequestsBloc>(friendRequestsBloc)
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
