import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:chat_app/core/notifications/notification_navigator.dart';
import 'package:chat_app/core/notifications/notification_service.dart';
import 'package:chat_app/features/auth/domain/entities/auth_user.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationService extends Mock implements NotificationService {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

void main() {
  const user = AuthUser(id: 'u1', email: 'a@b.com', displayName: 'Amy');
  const target = NotificationTarget(
    conversationId: 'c1',
    title: 'Ben',
  );

  late MockNotificationService notifications;
  late MockAuthBloc authBloc;
  late StreamController<NotificationTarget> taps;
  late GoRouter router;
  late List<String> pushedRoutes;

  setUp(() {
    notifications = MockNotificationService();
    authBloc = MockAuthBloc();
    taps = StreamController<NotificationTarget>.broadcast();
    pushedRoutes = [];

    when(() => notifications.conversationTaps).thenAnswer((_) => taps.stream);
    when(notifications.initialTarget).thenAnswer((_) async => null);

    router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
        GoRoute(
          path: '/conversation/:id',
          builder: (context, state) {
            pushedRoutes.add(state.uri.toString());
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  });

  tearDown(() async => taps.close());

  Future<void> pumpNavigator(WidgetTester tester) async {
    await tester.pumpWidget(
      NotificationNavigator(
        notificationService: notifications,
        router: router,
        authBloc: authBloc,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
  }

  testWidgets('opens the conversation when already signed in', (tester) async {
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthState.authenticated(user),
    );
    await pumpNavigator(tester);

    taps.add(target);
    await tester.pumpAndSettle();

    expect(pushedRoutes.single, contains('/conversation/c1'));
  });

  testWidgets('waits for the session to restore before opening',
      (tester) async {
    final states = StreamController<AuthState>.broadcast();
    whenListen(
      authBloc,
      states.stream,
      initialState: const AuthState.unknown(),
    );
    await pumpNavigator(tester);

    taps.add(target);
    await tester.pumpAndSettle();

    // Pushing now would be swallowed by the router's splash redirect.
    expect(pushedRoutes, isEmpty);

    whenListen(
      authBloc,
      states.stream,
      initialState: const AuthState.authenticated(user),
    );
    states.add(const AuthState.authenticated(user));
    await tester.pumpAndSettle();

    expect(pushedRoutes.single, contains('/conversation/c1'));
    await states.close();
  });

  testWidgets('ignores the tap when signed out', (tester) async {
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthState.unauthenticated(),
    );
    await pumpNavigator(tester);

    taps.add(target);
    await tester.pumpAndSettle();

    expect(pushedRoutes, isEmpty);
  });
}
