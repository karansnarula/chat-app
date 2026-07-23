part of 'settings_bloc.dart';

/// One-shot result of saving the display name.
sealed class SettingsOutcome extends Equatable {
  const SettingsOutcome();

  @override
  List<Object?> get props => [];
}

final class DisplayNameSavedOutcome extends SettingsOutcome {
  const DisplayNameSavedOutcome();
}

final class SettingsFailedOutcome extends SettingsOutcome {
  const SettingsFailedOutcome(this.exception);

  final AppException exception;

  @override
  List<Object?> get props => [exception];
}

class SettingsState extends Equatable {
  const SettingsState({
    required this.settings,
    this.isSavingDisplayName = false,
    this.outcome,
  });

  final AppSettings settings;
  final bool isSavingDisplayName;
  final SettingsOutcome? outcome;

  SettingsState copyWith({
    AppSettings? settings,
    bool? isSavingDisplayName,
    SettingsOutcome? outcome,
    bool clearOutcome = false,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isSavingDisplayName: isSavingDisplayName ?? this.isSavingDisplayName,
      outcome: clearOutcome ? null : outcome ?? this.outcome,
    );
  }

  @override
  List<Object?> get props => [settings, isSavingDisplayName, outcome];
}
