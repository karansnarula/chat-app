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

/// Floating frosted-glass navigation bar with a curved selection notch.
///
/// The selected destination lifts into a circle that protrudes above the
/// bar while the bar's top edge dips beneath it. Both the notch and the
/// circle are driven by a single animated slot position, so they stay in
/// step as selection slides between destinations.
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
    return SafeArea(
      minimum: const EdgeInsets.only(
        left: AppDimens.spaceL,
        right: AppDimens.spaceL,
        bottom: AppDimens.spaceM,
      ),
      child: SizedBox(
        height: AppDimens.navBarHeight + AppDimens.navCircleSize / 2,
        child: TweenAnimationBuilder<double>(
          tween: Tween(
            begin: currentIndex.toDouble(),
            end: currentIndex.toDouble(),
          ),
          duration: AppDurations.medium,
          curve: Curves.easeOutCubic,
          builder: (context, slot, _) => _NavBarContent(
            items: items,
            currentIndex: currentIndex,
            animatedSlot: slot,
            onDestinationSelected: onDestinationSelected,
          ),
        ),
      ),
    );
  }
}

class _NavBarContent extends StatelessWidget {
  const _NavBarContent({
    required this.items,
    required this.currentIndex,
    required this.animatedSlot,
    required this.onDestinationSelected,
  });

  final List<GlassNavItem> items;
  final int currentIndex;
  final double animatedSlot;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final glassColor = (isDark ? AppColors.glassDark : AppColors.glassLight)
        .withValues(alpha: isDark ? 0.55 : 0.7);

    return LayoutBuilder(
      builder: (context, constraints) {
        final slotWidth = constraints.maxWidth / items.length;
        final notchCenter = slotWidth * (animatedSlot + 0.5);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: AppDimens.navBarHeight,
              child: ClipPath(
                clipper: _NotchedBarClipper(notchCenter: notchCenter),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: AppDimens.glassBlur,
                    sigmaY: AppDimens.glassBlur,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: glassColor),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: AppDimens.navBarHeight,
              child: Row(
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
            ),
            Positioned(
              left: notchCenter - AppDimens.navCircleSize / 2,
              top: 0,
              width: AppDimens.navCircleSize,
              height: AppDimens.navCircleSize,
              child: IgnorePointer(
                child: _SelectionCircle(
                  icon: items[currentIndex].selectedIcon,
                  color: scheme.primary,
                  onColor: scheme.onPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Rounded bar whose top edge dips into a concave notch centred on the
/// selected destination.
class _NotchedBarClipper extends CustomClipper<Path> {
  const _NotchedBarClipper({required this.notchCenter});

  final double notchCenter;

  @override
  Path getClip(Size size) {
    const radius = AppDimens.radiusXl;
    const notchWidth = AppDimens.navNotchWidth;
    const notchDepth = AppDimens.navNotchDepth;
    const half = notchWidth / 2;

    return Path()
      ..moveTo(radius, 0)
      ..lineTo(notchCenter - half, 0)
      ..cubicTo(
        notchCenter - half * 0.5,
        0,
        notchCenter - half * 0.62,
        notchDepth,
        notchCenter,
        notchDepth,
      )
      ..cubicTo(
        notchCenter + half * 0.62,
        notchDepth,
        notchCenter + half * 0.5,
        0,
        notchCenter + half,
        0,
      )
      ..lineTo(size.width - radius, 0)
      ..arcToPoint(
        Offset(size.width, radius),
        radius: const Radius.circular(radius),
      )
      ..lineTo(size.width, size.height - radius)
      ..arcToPoint(
        Offset(size.width - radius, size.height),
        radius: const Radius.circular(radius),
      )
      ..lineTo(radius, size.height)
      ..arcToPoint(
        Offset(0, size.height - radius),
        radius: const Radius.circular(radius),
      )
      ..lineTo(0, radius)
      ..arcToPoint(
        const Offset(radius, 0),
        radius: const Radius.circular(radius),
      )
      ..close();
  }

  @override
  bool shouldReclip(_NotchedBarClipper oldClipper) =>
      oldClipper.notchCenter != notchCenter;
}

class _SelectionCircle extends StatelessWidget {
  const _SelectionCircle({
    required this.icon,
    required this.color,
    required this.onColor,
  });

  final IconData icon;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: AppDimens.spaceM,
            offset: const Offset(0, AppDimens.spaceXs),
          ),
        ],
      ),
      child: Icon(icon, color: onColor, size: AppDimens.iconM),
    );
  }
}

/// One destination: the label always shows; the icon hides while selected
/// because the floating circle carries it instead.
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

    return Semantics(
      selected: isSelected,
      button: true,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedOpacity(
              opacity: isSelected ? 0 : 1,
              duration: AppDurations.fast,
              child: Icon(
                item.icon,
                size: AppDimens.iconM,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimens.spaceXs),
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.spaceS),
              child: Text(
                item.label,
                maxLines: 1,
                softWrap: false,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
