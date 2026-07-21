import 'package:flutter/material.dart';

/// Central color palette.
///
/// The only place in the app where color values may be written literally.
/// Most colors should be consumed via `Theme.of(context).colorScheme`;
/// these tokens seed that scheme.
abstract final class AppColors {
  /// Brand orange — buttons, focus borders, toggles, the send button,
  /// the selected navigation destination, and the pending-requests dot.
  static const Color primary = Color(0xFFFF7A00);

  /// Muted orange for large filled areas in dark mode, where full-strength
  /// [primary] glares against near-black surfaces.
  static const Color primaryDeep = Color(0xFFC85F00);

  static const Color white = Color(0xFFFFFFFF);

  // Neutral surfaces. Kept deliberately untinted: a seeded Material 3
  // scheme would wash every surface with orange.
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color surfaceContainerLight = Color(0xFFF2F2F2);
  static const Color surfaceContainerDark = Color(0xFF1E1E1E);

  static const Color onSurfaceLight = Color(0xFF1A1A1A);
  static const Color onSurfaceDark = Color(0xFFF5F5F5);
  static const Color onSurfaceVariantLight = Color(0xFF6B6B6B);
  static const Color onSurfaceVariantDark = Color(0xFFA0A0A0);

  static const Color outlineLight = Color(0xFFE0E0E0);
  static const Color outlineDark = Color(0xFF3A3A3A);

  static const Color shimmerBaseLight = Color(0xFFEDEDED);
  static const Color shimmerHighlightLight = Color(0xFFF7F7F7);
  static const Color shimmerBaseDark = Color(0xFF2A2A2A);
  static const Color shimmerHighlightDark = Color(0xFF383838);
}
