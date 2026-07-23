import 'package:chat_app/core/constants/app_dimens.dart';
import 'package:chat_app/core/di/injection.dart';
import 'package:chat_app/core/error/app_exception_l10n.dart';
import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:chat_app/features/settings/presentation/widgets/display_name_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<SettingsBloc>(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  Future<void> _editDisplayName(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const DisplayNameDialog(),
    );
    if (name == null || !context.mounted) return;
    context.read<SettingsBloc>().add(SettingsDisplayNameSubmitted(name));
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      if (!context.mounted) return;
      context.read<AuthBloc>().add(const AuthLogoutRequested());
    }
  }

  void _showOutcome(BuildContext context, SettingsOutcome outcome) {
    final l10n = AppLocalizations.of(context);
    final message = switch (outcome) {
      DisplayNameSavedOutcome() => l10n.displayNameSaved,
      SettingsFailedOutcome(:final exception) =>
        exception.localizedMessage(l10n),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
    context.read<SettingsBloc>().add(const SettingsOutcomeCleared());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listenWhen: (previous, current) =>
            current.outcome != null && previous.outcome != current.outcome,
        listener: (context, state) => _showOutcome(context, state.outcome!),
        builder: (context, state) => ListView(
          padding: const EdgeInsets.only(
            bottom: AppDimens.navBarClearance,
          ),
          children: [
            _SectionHeader(title: l10n.profile),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(l10n.displayName),
              trailing: state.isSavingDisplayName
                  ? const SizedBox.square(
                      dimension: AppDimens.iconM,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: state.isSavingDisplayName
                  ? null
                  : () => _editDisplayName(context),
            ),
            const Divider(height: 1),
            _SectionHeader(title: l10n.appearance),
            _ThemeModeTile(current: state.settings.themeMode),
            const Divider(height: 1),
            _SectionHeader(title: l10n.language),
            _LanguageTile(current: state.settings.locale),
            const Divider(height: 1),
            const SizedBox(height: AppDimens.spaceM),
            ListTile(
              leading: Icon(
                Icons.logout_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                l10n.logout,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () => _confirmLogout(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.spaceM,
        AppDimens.spaceL,
        AppDimens.spaceM,
        AppDimens.spaceS,
      ),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({required this.current});

  final ThemeMode current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    String label(ThemeMode mode) => switch (mode) {
          ThemeMode.system => l10n.themeSystem,
          ThemeMode.light => l10n.themeLight,
          ThemeMode.dark => l10n.themeDark,
        };

    return ListTile(
      leading: const Icon(Icons.brightness_6_outlined),
      title: Text(l10n.theme),
      trailing: DropdownButton<ThemeMode>(
        value: current,
        underline: const SizedBox.shrink(),
        onChanged: (mode) {
          if (mode == null) return;
          context.read<SettingsBloc>().add(SettingsThemeModeChanged(mode));
        },
        items: [
          for (final mode in ThemeMode.values)
            DropdownMenuItem(value: mode, child: Text(label(mode))),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.current});

  final Locale? current;

  static const List<Locale?> _supported = [null, Locale('en'), Locale('th')];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    String label(Locale? locale) => switch (locale?.languageCode) {
          'en' => l10n.languageEnglish,
          'th' => l10n.languageThai,
          _ => l10n.languageSystem,
        };

    return ListTile(
      leading: const Icon(Icons.translate_rounded),
      title: Text(l10n.language),
      trailing: DropdownButton<String>(
        value: current?.languageCode ?? '',
        underline: const SizedBox.shrink(),
        onChanged: (code) {
          final locale = (code == null || code.isEmpty) ? null : Locale(code);
          context.read<SettingsBloc>().add(SettingsLocaleChanged(locale));
        },
        items: [
          for (final locale in _supported)
            DropdownMenuItem(
              value: locale?.languageCode ?? '',
              child: Text(label(locale)),
            ),
        ],
      ),
    );
  }
}
