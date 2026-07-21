import 'package:chat_app/core/constants/app_dimens.dart';
import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Hosts the bottom-nav destinations.
///
/// The bar floats clear of the screen edge, so content scrolls behind it;
/// scrollables inside the shell should pad their bottom by
/// [AppDimens.navBarClearance].
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
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: AppDimens.spaceS),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceM),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  selectedIcon: const Icon(Icons.chat_bubble_rounded),
                  label: l10n.chats,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings_rounded),
                  label: l10n.settings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
