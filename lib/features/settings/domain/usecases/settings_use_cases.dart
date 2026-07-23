import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/settings/domain/entities/app_settings.dart';
import 'package:chat_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@injectable
class ReadSettingsUseCase {
  const ReadSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  AppSettings call() => _repository.read();
}

@injectable
class SetThemeModeUseCase {
  const SetThemeModeUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(ThemeMode mode) => _repository.saveThemeMode(mode);
}

@injectable
class SetLocaleUseCase {
  const SetLocaleUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(Locale? locale) => _repository.saveLocale(locale);
}

@injectable
class UpdateDisplayNameUseCase {
  const UpdateDisplayNameUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Result<String>> call(String displayName) =>
      _repository.updateDisplayName(displayName);
}
