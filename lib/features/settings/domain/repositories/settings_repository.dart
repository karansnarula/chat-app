import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/settings/domain/entities/app_settings.dart';
import 'package:flutter/material.dart';

abstract interface class SettingsRepository {
  AppSettings read();

  Future<void> saveThemeMode(ThemeMode mode);

  Future<void> saveLocale(Locale? locale);

  Future<Result<String>> updateDisplayName(String displayName);
}
