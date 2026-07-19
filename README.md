# Chat App

[![CI](https://github.com/karansnarula/chat-app/actions/workflows/ci.yml/badge.svg)](https://github.com/karansnarula/chat-app/actions/workflows/ci.yml)

Real-time chat application built with Flutter — friends, one-on-one conversations, live messaging over WebSocket, and push notifications. Consumes the [chat-app-api](https://github.com/karansnarula/chat-app-api) NestJS backend.

> 🚧 Work in progress — full README (architecture, screenshots, setup) lands with the final phase.

## Development

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Generated code (`*.g.dart`, `*.config.dart`) is not committed; run `build_runner` after checkout. CI (GitHub Actions) analyzes, tests, and builds every push/PR to `develop`/`main`, and distributes Android builds to testers via Firebase App Distribution on pushes to `develop`.
