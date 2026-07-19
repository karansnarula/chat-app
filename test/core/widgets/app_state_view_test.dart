import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/core/widgets/app_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('renders title, message, and retry action', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      wrap(
        AppStateView(
          icon: Icons.wifi_off,
          title: 'No connection',
          message: 'Check your internet.',
          onRetry: () => retried = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No connection'), findsOneWidget);
    expect(find.text('Check your internet.'), findsOneWidget);

    await tester.tap(find.byType(AppStateRetryButton));
    expect(retried, isTrue);
  });

  testWidgets('hides retry button without a callback', (tester) async {
    await tester.pumpWidget(
      wrap(
        const AppStateView(
          icon: Icons.inbox,
          title: 'Empty',
          message: 'Nothing here yet.',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppStateRetryButton), findsNothing);
  });
}
