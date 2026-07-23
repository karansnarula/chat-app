// Drives the sign-in flow end to end: the real login screen, AuthBloc, and
// router, with the network faked at the use-case boundary so the test is
// deterministic. Runnable on a device with:
//   flutter test integration_test/sign_in_test.dart
import 'package:chat_app/core/di/injection.dart';
import 'package:chat_app/core/error/app_exception.dart';
import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/core/network/connectivity_service.dart';
import 'package:chat_app/core/router/app_router.dart';
import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/features/auth/domain/entities/auth_user.dart';
import 'package:chat_app/features/auth/domain/usecases/check_session_use_case.dart';
import 'package:chat_app/features/auth/domain/usecases/login_use_case.dart';
import 'package:chat_app/features/auth/domain/usecases/logout_use_case.dart';
import 'package:chat_app/features/auth/domain/usecases/register_use_case.dart';
import 'package:chat_app/features/auth/domain/usecases/watch_session_expiry_use_case.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/chats/domain/entities/conversation.dart';
import 'package:chat_app/features/chats/domain/usecases/get_conversations_use_case.dart';
import 'package:chat_app/features/chats/domain/usecases/watch_conversations_use_case.dart';
import 'package:chat_app/features/chats/presentation/bloc/chats_bloc.dart';
import 'package:chat_app/features/friend_requests/presentation/bloc/friend_requests_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockCheckSessionUseCase extends Mock implements CheckSessionUseCase {}

class MockWatchSessionExpiryUseCase extends Mock
    implements WatchSessionExpiryUseCase {}

class MockGetConversationsUseCase extends Mock
    implements GetConversationsUseCase {}

class MockWatchConversationsUseCase extends Mock
    implements WatchConversationsUseCase {}

class MockFriendRequestsBloc
    extends Mock
    implements FriendRequestsBloc {}

class FakeConnectivity extends Fake implements Connectivity {
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.value([ConnectivityResult.wifi]);

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      [ConnectivityResult.wifi];
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const user = AuthUser(id: 'u1', email: 'amy@test.com', displayName: 'Amy');

  late MockLoginUseCase login;
  late MockCheckSessionUseCase checkSession;
  late MockWatchSessionExpiryUseCase watchExpiry;
  late MockGetConversationsUseCase getConversations;

  setUp(() {
    login = MockLoginUseCase();
    checkSession = MockCheckSessionUseCase();
    watchExpiry = MockWatchSessionExpiryUseCase();
    getConversations = MockGetConversationsUseCase();

    // Start signed out; the login use case succeeds when invoked.
    when(checkSession.call).thenAnswer((_) async => false);
    when(watchExpiry.call).thenAnswer((_) => const Stream.empty());
    when(
      () => login(email: 'amy@test.com', password: 'password123'),
    ).thenAnswer((_) async => const Success(user));
    when(getConversations.call).thenAnswer(
      (_) async => Success([
        Conversation(
          id: 'c1',
          otherUser: const ConversationUser(
            id: 'u2',
            displayName: 'Ben',
            email: 'ben@test.com',
          ),
          unreadCount: 0,
          lastMessage: LastMessage(
            id: 'm1',
            content: 'Hey Amy!',
            senderId: 'u2',
            createdAt: DateTime.now(),
          ),
        ),
      ]),
    );

    final authBloc = AuthBloc(
      login,
      MockRegisterUseCase(),
      MockLogoutUseCase(),
      checkSession,
      watchExpiry,
    );

    final friendRequestsBloc = MockFriendRequestsBloc();
    when(() => friendRequestsBloc.state)
        .thenReturn(const FriendRequestsState());
    when(() => friendRequestsBloc.stream)
        .thenAnswer((_) => const Stream.empty());

    final watchConversations = MockWatchConversationsUseCase();
    when(watchConversations.call).thenAnswer((_) => const Stream.empty());

    getIt
      ..registerSingleton<AuthBloc>(authBloc)
      ..registerSingleton<FriendRequestsBloc>(friendRequestsBloc)
      ..registerSingleton<ConnectivityService>(
        ConnectivityService(FakeConnectivity()),
      )
      ..registerFactory<ChatsBloc>(
        () => ChatsBloc(getConversations, watchConversations),
      )
      ..registerLazySingleton<GoRouter>(() => AppRouter.create(authBloc));
  });

  tearDown(getIt.reset);

  Widget harness() => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: getIt<AuthBloc>()),
          BlocProvider.value(value: getIt<FriendRequestsBloc>()),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: getIt<GoRouter>(),
        ),
      );

  testWidgets('signs in and lands on the chats list', (tester) async {
    getIt<AuthBloc>().add(const AuthCheckRequested());
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    // Starts on the login screen.
    expect(find.text('Welcome back'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      'amy@test.com',
    );
    await tester.enterText(
      find.byType(TextFormField).last,
      'password123',
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
    await tester.pumpAndSettle();

    // Landed on the chats list with the seeded conversation.
    expect(find.text('Ben'), findsOneWidget);
    expect(find.text('Hey Amy!'), findsOneWidget);
    verify(() => login(email: 'amy@test.com', password: 'password123'))
        .called(1);
  });

  testWidgets('shows an error and stays on login for bad credentials',
      (tester) async {
    when(
      () => login(email: 'amy@test.com', password: 'wrong'),
    ).thenAnswer(
      (_) async => const Failure(UnauthorizedException('Invalid credentials')),
    );

    getIt<AuthBloc>().add(const AuthCheckRequested());
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'amy@test.com');
    await tester.enterText(find.byType(TextFormField).last, 'wrong');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid credentials'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
