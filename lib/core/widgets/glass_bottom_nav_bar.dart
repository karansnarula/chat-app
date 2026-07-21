import 'dart:ui';

import 'package:chat_app/core/constants/app_colors.dart';
import 'package:chat_app/core/constants/app_dimens.dart';
import 'package:chat_app/core/constants/app_durations.dart';
import 'package:flutter/material.dart';

class GlassNavItem {
  const GlassNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Floating frosted-glass navigation bar.
///
/// A [BackdropFilter] blurs whatever scrolls beneath a translucent pill.
/// Every destination keeps its icon and label; selection is marked by a
/// rounded highlight that slides between slots.
class GlassBottomNavBar extends StatelessWidget {
  const GlassBottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final List<GlassNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final glassColor = (isDark ? AppColors.glassDark : AppColors.glassLight)
        .withValues(alpha: isDark ? 0.6 : 0.72);

    return SafeArea(
      minimum: const EdgeInsets.only(
        left: AppDimens.spaceL,
        right: AppDimens.spaceL,
        bottom: AppDimens.spaceM,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppDimens.glassBlur,
            sigmaY: AppDimens.glassBlur,
          ),
          child: Container(
            height: AppDimens.navBarHeight,
            padding: const EdgeInsets.all(AppDimens.spaceXs),
            decoration: BoxDecoration(
              color: glassColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              border: Border.all(
                color: scheme.onSurface.withValues(alpha: 0.06),
              ),
            ),
            child: Stack(
              children: [
                _SelectionHighlight(
                  slotCount: items.length,
                  currentIndex: currentIndex,
                  color: scheme.primary.withValues(alpha: 0.2),
                ),
                Row(
                  children: [
                    for (var index = 0; index < items.length; index++)
                      Expanded(
                        child: _NavSlot(
                          item: items[index],
                          isSelected: index == currentIndex,
                          onTap: () => onDestinationSelected(index),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded pill that slides to sit behind the selected destination.
class _SelectionHighlight extends StatelessWidget {
  const _SelectionHighlight({
    required this.slotCount,
    required this.currentIndex,
    required this.color,
  });

  final int slotCount;
  final int currentIndex;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // -1 maps the first slot to the left edge and the last to the right.
    final alignmentX =
        slotCount == 1 ? 0.0 : (currentIndex / (slotCount - 1)) * 2 - 1;

    return AnimatedAlign(
      alignment: Alignment(alignmentX, 0),
      duration: AppDurations.medium,
      curve: Curves.easeOutCubic,
      child: FractionallySizedBox(
        widthFactor: 1 / slotCount,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          ),
        ),
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final GlassNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = isSelected ? scheme.primary : scheme.onSurfaceVariant;

    return Semantics(
      selected: isSelected,
      button: true,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: AppDurations.fast,
              child: Icon(
                isSelected ? item.selectedIcon : item.icon,
                key: ValueKey(isSelected),
                size: AppDimens.iconM,
                color: color,
              ),
            ),
            const SizedBox(height: AppDimens.spaceXs),
            AnimatedDefaultTextStyle(
              duration: AppDurations.fast,
              style: theme.textTheme.labelSmall!.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(item.label, maxLines: 1, softWrap: false),
            ),
          ],
        ),
      ),
    );
  }
}
