import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppSettings extends Equatable {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale,
  });

  final ThemeMode themeMode;

  /// Null follows the device language.
  final Locale? locale;

  AppSettings copyWith({
    ThemeMode? mode,
    Locale? locale,
    bool clearLocale = false,
  }) {
    return AppSettings(
      themeMode: mode ?? themeMode,
      locale: clearLocale ? null : locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale];
}
