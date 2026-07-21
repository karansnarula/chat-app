import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Hosts the bottom-nav destinations.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onDestinationSelected,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: const Icon(Icons.chat_bubble_rounded),
            label: l10n.chats,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings_rounded),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
