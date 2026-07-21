import 'package:chat_app/core/constants/app_dimens.dart';
import 'package:chat_app/core/constants/app_durations.dart';
import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wave_bottom_bar/bottom_bar.dart';

/// Hosts the bottom-nav destinations.
///
/// [WaveBottomBar] owns its selected index internally, so external changes
/// (deep links, programmatic navigation) are pushed in through
/// [WaveBarController] rather than by rebuilding with a new index.
class AppShell extends StatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _barController = WaveBarController();

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final index = widget.navigationShell.currentIndex;
    if (index != oldWidget.navigationShell.currentIndex) {
      _barController.animateToIndex(index);
    }
  }

  @override
  void dispose() {
    _barController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: WaveBottomBar(
        controller: _barController,
        initialIndex: widget.navigationShell.currentIndex,
        onTap: _onDestinationSelected,
        height: AppDimens.navBarHeight,
        amplitude: AppDimens.waveAmplitude,
        waveLength: AppDimens.waveLength,
        corner: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusXl),
        ),
        duration: AppDurations.medium,
        curve: Curves.easeOutCubic,
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
