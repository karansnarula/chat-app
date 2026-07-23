part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

final class SettingsThemeModeChanged extends SettingsEvent {
  const SettingsThemeModeChanged(this.mode);

  final ThemeMode mode;

  @override
  List<Object?> get props => [mode];
}

final class SettingsLocaleChanged extends SettingsEvent {
  const SettingsLocaleChanged(this.locale);

  /// Null follows the device language.
  final Locale? locale;

  @override
  List<Object?> get props => [locale];
}

final class SettingsDisplayNameSubmitted extends SettingsEvent {
  const SettingsDisplayNameSubmitted(this.displayName);

  final String displayName;

  @override
  List<Object?> get props => [displayName];
}

final class SettingsOutcomeCleared extends SettingsEvent {
  const SettingsOutcomeCleared();
}
