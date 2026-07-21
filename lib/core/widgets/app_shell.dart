import 'dart:async';

import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/core/widgets/glass_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Hosts the bottom-nav destinations. Content extends behind the floating
/// bar so the frosted blur has something to work with.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    unawaited(HapticFeedback.selectionClick());
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: GlassBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        items: [
          GlassNavItem(
            icon: Icons.chat_bubble_outline_rounded,
            selectedIcon: Icons.chat_bubble_rounded,
            label: l10n.chats,
          ),
          GlassNavItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings_rounded,
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
