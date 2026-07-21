import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/core/widgets/glass_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _items = [
  GlassNavItem(
    icon: Icons.chat_bubble_outline_rounded,
    selectedIcon: Icons.chat_bubble_rounded,
    label: 'Chats',
  ),
  GlassNavItem(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
    label: 'Settings',
  ),
];

Widget wrap({required int currentIndex, ValueChanged<int>? onSelected}) =>
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        bottomNavigationBar: GlassBottomNavBar(
          items: _items,
          currentIndex: currentIndex,
          onDestinationSelected: onSelected ?? (_) {},
        ),
      ),
    );

void main() {
  testWidgets('shows every label and lifts the selected icon into the circle',
      (tester) async {
    await tester.pumpWidget(wrap(currentIndex: 0));
    await tester.pumpAndSettle();

    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    // Selected icon rides in the floating circle.
    expect(find.byIcon(Icons.chat_bubble_rounded), findsOneWidget);
    // Unselected keeps its outline icon in the bar.
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('reports the tapped destination index', (tester) async {
    int? selected;
    await tester.pumpWidget(
      wrap(currentIndex: 0, onSelected: (index) => selected = index),
    );

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(selected, 1);
  });
}
