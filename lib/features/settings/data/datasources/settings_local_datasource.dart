import 'package:chat_app/features/settings/domain/entities/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class SettingsLocalDataSource {
  const SettingsLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  static const _themeModeKey = 'theme_mode';
  static const _localeKey = 'locale';

  AppSettings read() {
    final storedTheme = _preferences.getString(_themeModeKey);
    final storedLocale = _preferences.getString(_localeKey);

    return AppSettings(
      themeMode: ThemeMode.values.asNameMap()[storedTheme] ?? ThemeMode.system,
      locale: storedLocale == null ? null : Locale(storedLocale),
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) =>
      _preferences.setString(_themeModeKey, mode.name);

  Future<void> saveLocale(Locale? locale) => locale == null
      ? _preferences.remove(_localeKey)
      : _preferences.setString(_localeKey, locale.languageCode);
}
