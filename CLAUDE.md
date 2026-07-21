# CLAUDE.md

Flutter chat app (iOS + Android) consuming the NestJS `chat-app-api` backend
(deployed at `https://chat-app-api-ayhv.onrender.com`, Swagger at `/api-docs`).
Portfolio project — code is read cold by reviewers, so clarity and consistency
win over cleverness.

## Toolchain

Flutter is installed via **fvm** and is **not** on the default PATH. Prefix
commands, e.g. `~/fvm/default/bin/flutter analyze`, or add it to PATH first.

```sh
flutter pub get
flutter gen-l10n                                   # localizations
dart run build_runner build --delete-conflicting-outputs   # DI, retrofit, json
flutter analyze
flutter test
```

Generated files (`*.g.dart`, `*.config.dart`, `lib/core/l10n/generated/`) are
gitignored; regenerate after checkout. CI runs the same steps.

## Architecture

Clean architecture, feature-first. Each feature has three layers:

```
lib/
├── core/       constants, error, network, storage, router, theme, l10n, di, widgets
└── features/<feature>/
    ├── data/          models (DTOs), datasources (retrofit API), repository impls
    ├── domain/        entities, repository interfaces, use cases
    └── presentation/  bloc, screens, widgets
```

- **State management: Bloc everywhere.** No Cubit, no FutureBuilder screens.
  Events → bloc → Equatable states; screens dispatch events and render states.
- **Use cases in every feature**, even thin pass-throughs — structural
  consistency and a uniform mocking seam. Blocs call use cases, never
  repositories directly.
- **DTOs vs entities**: `*Dto` types live in `data/` and map the wire format;
  `.toEntity()` converts to domain entities. DTOs must not leak past the
  repository.
- **Cross-feature communication** goes through repository-exposed typed
  streams (e.g. `SessionManager`), never direct bloc-to-bloc references and no
  event bus.

## Error handling: `Result<T>`

Repositories and use cases return `Future<Result<T>>` (`core/error/result.dart`),
a sealed `Success`/`Failure`. Blocs handle both with an exhaustive `switch`.
`guard()` (`core/error/api_guard.dart`) is the **only** try/catch — it converts
Dio/unknown exceptions into `Failure(AppException)`. Use `Result` only where
failure is a meaningful, handleable outcome (not for infallible calls like
`logout()` or bool reads).

## Conventions

- **No hard-coded values.** Colors, spacing/radii, font sizes, and durations
  live in `core/constants/` (`AppColors`, `AppDimens`, `AppFontSizes`,
  `AppDurations`). Widgets use tokens or `Theme.of(context)`, never literals.
- **All user-facing text is localized** (en + th) via `.arb` files in
  `core/l10n/arb/`. Only non-translatable constants go in `AppStrings`.
- **Comments are minimal** — only for complex, non-obvious, or special-purpose
  code. Let names carry the rest.
- **Networking**: dio + retrofit; `AuthInterceptor` attaches the access token
  and transparently refreshes on 401. Tokens are stored in
  `flutter_secure_storage`.
- **Tests**: `bloc_test` + `mocktail`. Every bloc, repository, and key screen
  gets coverage. Keep `flutter analyze` clean (`very_good_analysis`).

## Workflow

Built in reviewed phases. Each phase ends with tests passing, `flutter analyze`
clean, and one conventional commit (`feat:`, `refactor:`, `ci:`, …). Work on
`develop`; pushes there distribute an Android build via Firebase App
Distribution.
