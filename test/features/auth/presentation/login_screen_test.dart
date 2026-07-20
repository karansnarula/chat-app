import 'package:bloc_test/bloc_test.dart';
import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;

  setUpAll(() {
    registerFallbackValue(const AuthCheckRequested());
  });

  setUp(() {
    authBloc = MockAuthBloc();
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthState.unauthenticated(),
    );
  });

  Widget wrap() => MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const LoginScreen(),
        ),
      );

  testWidgets('shows validation errors and does not submit', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.text('Log In'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    verifyNever(() => authBloc.add(any()));
  });

  testWidgets('dispatches AuthLoginSubmitted with trimmed email',
      (tester) async {
    await tester.pumpWidget(wrap());

    await tester.enterText(
      find.byType(TextFormField).first,
      ' karan@test.com ',
    );
    await tester.enterText(find.byType(TextFormField).last, 'password1');
    await tester.tap(find.text('Log In'));
    await tester.pump();

    verify(
      () => authBloc.add(
        const AuthLoginSubmitted(
          email: 'karan@test.com',
          password: 'password1',
        ),
      ),
    ).called(1);
  });
}
