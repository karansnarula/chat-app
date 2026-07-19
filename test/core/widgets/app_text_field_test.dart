import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) =>
    MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));

void main() {
  testWidgets('renders label', (tester) async {
    await tester.pumpWidget(wrap(const AppTextField(label: 'Email')));
    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('obscure toggle flips visibility', (tester) async {
    await tester.pumpWidget(
      wrap(const AppTextField(label: 'Password', obscureText: true)),
    );

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });
}
