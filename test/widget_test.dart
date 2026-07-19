import 'package:chat_app/core/di/injection.dart';
import 'package:chat_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  setUp(() {
    getIt.registerSingleton<GoRouter>(
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
