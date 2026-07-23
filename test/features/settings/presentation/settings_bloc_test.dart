import 'package:bloc_test/bloc_test.dart';
import 'package:chat_app/core/error/app_exception.dart';
import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/settings/domain/entities/app_settings.dart';
import 'package:chat_app/features/settings/domain/usecases/settings_use_cases.dart';
import 'package:chat_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockReadSettings extends Mock implements ReadSettingsUseCase {}

class MockSetThemeMode extends Mock implements SetThemeModeUseCase {}

class MockSetLocale extends Mock implements SetLocaleUseCase {}

class MockUpdateDisplayName extends Mock implements UpdateDisplayNameUseCase {}

void main() {
  late MockReadSettings readSettings;
  late MockSetThemeMode setThemeMode;
  late MockSetLocale setLocale;
  late MockUpdateDisplayName updateDisplayName;

  setUpAll(() {
    registerFallbackValue(const Locale('en'));
    registerFallbackValue(ThemeMode.system);
  });

  setUp(() {
    readSettings = MockReadSettings();
    setThemeMode = MockSetThemeMode();
    setLocale = MockSetLocale();
    updateDisplayName = MockUpdateDisplayName();

    when(readSettings.call).thenReturn(const AppSettings());
    when(() => setThemeMode(any())).thenAnswer((_) async {});
    when(() => setLocale(any())).thenAnswer((_) async {});
  });

  SettingsBloc buildBloc() => SettingsBloc(
        readSettings,
        setThemeMode,
        setLocale,
        updateDisplayName,
      );

  test('starts from the stored settings', () {
    when(readSettings.call).thenReturn(
      const AppSettings(themeMode: ThemeMode.dark, locale: Locale('th')),
    );

    final bloc = buildBloc();

    expect(bloc.state.settings.themeMode, ThemeMode.dark);
    expect(bloc.state.settings.locale, const Locale('th'));
  });

  blocTest<SettingsBloc, SettingsState>(
    'persists and applies the chosen theme',
    build: buildBloc,
    act: (bloc) => bloc.add(const SettingsThemeModeChanged(ThemeMode.dark)),
    verify: (bloc) {
      expect(bloc.state.settings.themeMode, ThemeMode.dark);
      verify(() => setThemeMode(ThemeMode.dark)).called(1);
    },
  );

  blocTest<SettingsBloc, SettingsState>(
    'persists and applies the chosen language',
    build: buildBloc,
    act: (bloc) => bloc.add(const SettingsLocaleChanged(Locale('th'))),
    verify: (bloc) {
      expect(bloc.state.settings.locale, const Locale('th'));
      verify(() => setLocale(const Locale('th'))).called(1);
    },
  );

  blocTest<SettingsBloc, SettingsState>(
    'clears the language back to the device default',
    build: buildBloc,
    seed: () => const SettingsState(
      settings: AppSettings(locale: Locale('th')),
    ),
    act: (bloc) => bloc.add(const SettingsLocaleChanged(null)),
    verify: (bloc) => expect(bloc.state.settings.locale, isNull),
  );

  group('display name', () {
    blocTest<SettingsBloc, SettingsState>(
      'reports success and trims the name',
      build: buildBloc,
      setUp: () => when(() => updateDisplayName('Karan'))
          .thenAnswer((_) async => const Success('Karan')),
      act: (bloc) => bloc.add(const SettingsDisplayNameSubmitted('  Karan  ')),
      verify: (bloc) {
        expect(bloc.state.outcome, isA<DisplayNameSavedOutcome>());
        expect(bloc.state.isSavingDisplayName, isFalse);
        verify(() => updateDisplayName('Karan')).called(1);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'surfaces the server message on failure',
      build: buildBloc,
      setUp: () => when(() => updateDisplayName(any())).thenAnswer(
        (_) async => const Failure(
          ServerException('Name too long', statusCode: 400),
        ),
      ),
      act: (bloc) => bloc.add(const SettingsDisplayNameSubmitted('Karan')),
      verify: (bloc) {
        final outcome = bloc.state.outcome! as SettingsFailedOutcome;
        expect(outcome.exception.message, 'Name too long');
        expect(bloc.state.isSavingDisplayName, isFalse);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'clears the outcome once shown',
      build: buildBloc,
      seed: () => const SettingsState(
        settings: AppSettings(),
        outcome: DisplayNameSavedOutcome(),
      ),
      act: (bloc) => bloc.add(const SettingsOutcomeCleared()),
      verify: (bloc) => expect(bloc.state.outcome, isNull),
    );
  });
}
