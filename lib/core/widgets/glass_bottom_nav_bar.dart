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
/// A [BackdropFilter] blurs whatever scrolls beneath a translucent pill,
/// and the selected destination is marked by a rounded highlight that
/// slides between slots while its label expands into view.
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
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassColor = (isDark ? AppColors.glassDark : AppColors.glassLight)
        .withValues(alpha: isDark ? 0.55 : 0.65);

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
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spaceS,
            ),
            decoration: BoxDecoration(
              color: glassColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              border: Border.all(
                color: scheme.onSurface.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.12),
                  blurRadius: AppDimens.glassShadowBlur,
                  offset: const Offset(0, AppDimens.spaceS),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var index = 0; index < items.length; index++)
                  _NavDestination(
                    item: items[index],
                    isSelected: index == currentIndex,
                    onTap: () => onDestinationSelected(index),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavDestination extends StatelessWidget {
  const _NavDestination({
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

    return Semantics(
      selected: isSelected,
      button: true,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        child: AnimatedContainer(
          duration: AppDurations.medium,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spaceM,
            vertical: AppDimens.spaceS,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? scheme.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? item.selectedIcon : item.icon,
                size: AppDimens.iconM,
                color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
              ),
              // Width animates from zero so the label grows out of the icon;
              // the fade hides the clipping that resizing would otherwise show.
              AnimatedSize(
                duration: AppDurations.medium,
                curve: Curves.easeOutCubic,
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(
                          left: AppDimens.spaceS,
                        ),
                        child: AnimatedOpacity(
                          opacity: isSelected ? 1 : 0,
                          duration: AppDurations.medium,
                          child: Text(
                            item.label,
                            maxLines: 1,
                            softWrap: false,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
