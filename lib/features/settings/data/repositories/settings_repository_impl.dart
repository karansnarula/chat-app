import 'package:chat_app/core/error/api_guard.dart';
import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/settings/data/datasources/settings_api.dart';
import 'package:chat_app/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:chat_app/features/settings/data/models/update_profile_dto.dart';
import 'package:chat_app/features/settings/domain/entities/app_settings.dart';
import 'package:chat_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._local, this._api);

  final SettingsLocalDataSource _local;
  final SettingsApi _api;

  @override
  AppSettings read() => _local.read();

  @override
  Future<void> saveThemeMode(ThemeMode mode) => _local.saveThemeMode(mode);

  @override
  Future<void> saveLocale(Locale? locale) => _local.saveLocale(locale);

  @override
  Future<Result<String>> updateDisplayName(String displayName) async {
    final result = await guard(
      () => _api.updateDisplayName(UpdateProfileDto(displayName: displayName)),
    );
    return switch (result) {
      Success(:final value) => Success(value.displayName),
      Failure(:final exception) => Failure(exception),
    };
  }
}
