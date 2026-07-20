import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:chat_app/core/error/app_exception.dart';
import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/auth/domain/entities/auth_user.dart';
import 'package:chat_app/features/auth/domain/usecases/check_session_use_case.dart';
import 'package:chat_app/features/auth/domain/usecases/login_use_case.dart';
import 'package:chat_app/features/auth/domain/usecases/logout_use_case.dart';
import 'package:chat_app/features/auth/domain/usecases/register_use_case.dart';
import 'package:chat_app/features/auth/domain/usecases/watch_session_expiry_use_case.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockCheckSessionUseCase extends Mock implements CheckSessionUseCase {}

class MockWatchSessionExpiryUseCase extends Mock
    implements WatchSessionExpiryUseCase {}

void main() {
  const user = AuthUser(id: 'u1', email: 'k@n.com', displayName: 'Karan');

  late MockLoginUseCase login;
  late MockRegisterUseCase register;
  late MockLogoutUseCase logout;
  late MockCheckSessionUseCase checkSession;
  late MockWatchSessionExpiryUseCase watchExpiry;
  late StreamController<void> expiryController;

  setUp(() {
    login = MockLoginUseCase();
    register = MockRegisterUseCase();
    logout = MockLogoutUseCase();
    checkSession = MockCheckSessionUseCase();
    watchExpiry = MockWatchSessionExpiryUseCase();
    expiryController = StreamController<void>.broadcast();
    when(watchExpiry.call).thenAnswer((_) => expiryController.stream);
  });

  tearDown(() => expiryController.close());

  AuthBloc buildBloc() =>
      AuthBloc(login, register, logout, checkSession, watchExpiry);

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits authenticated when a session exists',
      build: buildBloc,
      setUp: () =>
          when(checkSession.call).thenAnswer((_) async => true),
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthState.authenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated when no session exists',
      build: buildBloc,
      setUp: () =>
          when(checkSession.call).thenAnswer((_) async => false),
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthState.unauthenticated()],
    );
  });

  group('AuthLoginSubmitted', () {
    blocTest<AuthBloc, AuthState>(
      'emits submitting then authenticated on success',
      build: buildBloc,
      setUp: () => when(
        () => login(email: 'k@n.com', password: 'password1'),
      ).thenAnswer((_) async => const Success(user)),
      act: (bloc) => bloc.add(
        const AuthLoginSubmitted(email: 'k@n.com', password: 'password1'),
      ),
      expect: () => [
        const AuthState.unauthenticated(isSubmitting: true),
        const AuthState.authenticated(user),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits submitting then failure on error',
      build: buildBloc,
      setUp: () => when(
        () => login(email: 'k@n.com', password: 'wrong'),
      ).thenAnswer(
        (_) async =>
            const Failure(UnauthorizedException('Invalid credentials')),
      ),
      act: (bloc) => bloc.add(
        const AuthLoginSubmitted(email: 'k@n.com', password: 'wrong'),
      ),
      expect: () => [
        const AuthState.unauthenticated(isSubmitting: true),
        const AuthState.unauthenticated(
          failure: UnauthorizedException('Invalid credentials'),
        ),
      ],
    );
  });

  group('AuthRegisterSubmitted', () {
    blocTest<AuthBloc, AuthState>(
      'emits submitting then authenticated on success',
      build: buildBloc,
      setUp: () => when(
        () => register(
          email: 'k@n.com',
          password: 'password1',
          displayName: 'Karan',
        ),
      ).thenAnswer((_) async => const Success(user)),
      act: (bloc) => bloc.add(
        const AuthRegisterSubmitted(
          email: 'k@n.com',
          password: 'password1',
          displayName: 'Karan',
        ),
      ),
      expect: () => [
        const AuthState.unauthenticated(isSubmitting: true),
        const AuthState.authenticated(user),
      ],
    );
  });

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated after logging out',
      build: buildBloc,
      seed: () => const AuthState.authenticated(user),
      setUp: () => when(logout.call).thenAnswer((_) async {}),
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [const AuthState.unauthenticated()],
      verify: (_) => verify(logout.call).called(1),
    );
  });

  group('session expiry', () {
    blocTest<AuthBloc, AuthState>(
      'forces unauthenticated when the expiry stream fires',
      build: buildBloc,
      seed: () => const AuthState.authenticated(user),
      act: (_) => expiryController.add(null),
      expect: () => [const AuthState.unauthenticated()],
    );
  });
}
