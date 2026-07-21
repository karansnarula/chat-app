import 'package:chat_app/core/constants/app_colors.dart';
import 'package:chat_app/core/constants/app_dimens.dart';
import 'package:chat_app/core/constants/app_font_sizes.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    // Neutral roles are overridden so surfaces stay white/grey; a seeded
    // Material 3 scheme would tint every surface with the brand orange.
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.primary,
      surface: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
      surfaceContainerHighest: isLight
          ? AppColors.surfaceContainerLight
          : AppColors.surfaceContainerDark,
      onSurface: isLight ? AppColors.onSurfaceLight : AppColors.onSurfaceDark,
      onSurfaceVariant: isLight
          ? AppColors.onSurfaceVariantLight
          : AppColors.onSurfaceVariantDark,
      outlineVariant: isLight ? AppColors.outlineLight : AppColors.outlineDark,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spaceM,
          vertical: AppDimens.spaceM,
        ),
        border: _inputBorder(scheme.outlineVariant),
        enabledBorder: _inputBorder(scheme.outlineVariant),
        focusedBorder: _inputBorder(
          scheme.primary,
          width: AppDimens.textFieldFocusBorderWidth,
        ),
        errorBorder: _inputBorder(scheme.error),
        focusedErrorBorder: _inputBorder(
          scheme.error,
          width: AppDimens.textFieldFocusBorderWidth,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.primary.withValues(alpha: 0.4),
          disabledForegroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusL),
          ),
          textStyle: const TextStyle(
            fontSize: AppFontSizes.l,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: scheme.primary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surfaceContainerHighest,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: AppDimens.navBarHeight,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
        indicatorShape: const StadiumBorder(),
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: AppDimens.iconNav,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: AppFontSizes.s,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
        ),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(
    Color color, {
    double width = AppDimens.textFieldBorderWidth,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusL),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontSize: AppFontSizes.display,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: AppFontSizes.xxl,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: AppFontSizes.xl,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: AppFontSizes.l,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: AppFontSizes.l),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: AppFontSizes.m),
      bodySmall: base.bodySmall?.copyWith(fontSize: AppFontSizes.s),
      labelSmall: base.labelSmall?.copyWith(fontSize: AppFontSizes.xs),
    );
  }
}
