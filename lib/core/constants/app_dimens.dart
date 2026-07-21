/// Spacing, radii, and size tokens. The only place layout numbers
/// may be written literally.
abstract final class AppDimens {
  // Spacing
  static const double spaceXs = 4;
  static const double spaceS = 8;
  static const double spaceM = 16;
  static const double spaceL = 24;
  static const double spaceXl = 32;
  static const double spaceXxl = 48;

  // Corner radii
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXl = 24;
  static const double radiusPill = 100;

  // Icons
  static const double iconS = 16;
  static const double iconM = 24;
  static const double iconL = 32;
  static const double iconXl = 48;

  // Components
  static const double buttonHeight = 52;
  static const double textFieldBorderWidth = 1;
  static const double textFieldFocusBorderWidth = 2;
  static const double avatarRadius = 24;
  static const double stateViewIconCircle = 96;

  /// Navigation destination icons, sized up from [iconM] for legibility.
  static const double iconNav = 28;
  static const double navBarHeight = 68;
}
