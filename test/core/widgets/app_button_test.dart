import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) =>
    MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));

void main() {
  testWidgets('renders label and handles tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrap(AppButton(label: 'Send', onPressed: () => tapped = true)),
    );

    await tester.tap(find.text('Send'));
    expect(tapped, isTrue);
  });

  testWidgets('shows spinner and blocks taps while loading', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrap(
        AppButton(
          label: 'Send',
          isLoading: true,
          onPressed: () => tapped = true,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Send'), findsNothing);

    await tester.tap(find.byType(AppButton), warnIfMissed: false);
    expect(tapped, isFalse);
  });
}
