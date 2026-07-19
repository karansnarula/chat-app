import 'package:flutter/material.dart';

/// Central color palette.
///
/// The only place in the app where color values may be written literally.
/// Most colors should be consumed via `Theme.of(context).colorScheme`;
/// these tokens exist for the seed and for colors outside the scheme.
abstract final class AppColors {
  /// Brand orange — seeds the color scheme; used for buttons, focus
  /// borders, toggles, the send button, and the pending-requests dot.
  static const Color primary = Color(0xFFFF7A00);

  static const Color white = Color(0xFFFFFFFF);

  static const Color shimmerBaseLight = Color(0xFFEDEDED);
  static const Color shimmerHighlightLight = Color(0xFFF7F7F7);
  static const Color shimmerBaseDark = Color(0xFF2A2A2A);
  static const Color shimmerHighlightDark = Color(0xFF383838);
}
