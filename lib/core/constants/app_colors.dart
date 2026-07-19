import 'package:flutter/material.dart';

/// Central color palette.
///
/// The only place in the app where color values may be written literally.
/// Widgets consume colors via [ThemeData]/`ColorScheme` or these tokens.
abstract final class AppColors {
  /// Brand orange — seeds the color scheme; used for buttons, focus borders,
  /// toggles, the send button, and the pending-requests dot.
  static const Color primary = Color(0xFFFF7A00);

  static const Color white = Color(0xFFFFFFFF);
}
