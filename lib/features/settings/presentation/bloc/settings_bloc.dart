import 'package:chat_app/core/error/app_exception.dart';
import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/settings/domain/entities/app_settings.dart';
import 'package:chat_app/features/settings/domain/usecases/settings_use_cases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'settings_event.dart';
part 'settings_state.dart';

/// App-scoped: the root widget restyles itself from this state, and the
/// settings screen edits the same instance.
@lazySingleton
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(
    ReadSettingsUseCase readSettings,
    this._setThemeMode,
    this._setLocale,
    this._updateDisplayName,
  ) : super(SettingsState(settings: readSettings())) {
    on<SettingsThemeModeChanged>(_onThemeModeChanged);
    on<SettingsLocaleChanged>(_onLocaleChanged);
    on<SettingsDisplayNameSubmitted>(_onDisplayNameSubmitted);
    on<SettingsOutcomeCleared>(_onOutcomeCleared);
  }

  final SetThemeModeUseCase _setThemeMode;
  final SetLocaleUseCase _setLocale;
  final UpdateDisplayNameUseCase _updateDisplayName;

  Future<void> _onThemeModeChanged(
    SettingsThemeModeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await _setThemeMode(event.mode);
    emit(state.copyWith(settings: state.settings.copyWith(mode: event.mode)));
  }

  Future<void> _onLocaleChanged(
    SettingsLocaleChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await _setLocale(event.locale);
    emit(
      state.copyWith(
        settings: state.settings.copyWith(
          locale: event.locale,
          clearLocale: event.locale == null,
        ),
      ),
    );
  }

  Future<void> _onDisplayNameSubmitted(
    SettingsDisplayNameSubmitted event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isSavingDisplayName: true));

    final result = await _updateDisplayName(event.displayName.trim());

    switch (result) {
      case Success():
        emit(
          state.copyWith(
            isSavingDisplayName: false,
            outcome: const DisplayNameSavedOutcome(),
          ),
        );
      case Failure(:final exception):
        emit(
          state.copyWith(
            isSavingDisplayName: false,
            outcome: SettingsFailedOutcome(exception),
          ),
        );
    }
  }

  void _onOutcomeCleared(
    SettingsOutcomeCleared event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(clearOutcome: true));
  }
}
