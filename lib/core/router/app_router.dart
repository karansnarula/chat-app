import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/core/router/app_routes.dart';
import 'package:chat_app/core/storage/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Route table with an auth-aware redirect skeleton.
///
/// Placeholder screens are replaced feature-by-feature in later phases;
/// the splash route stays neutral until the auth feature owns the
/// initial-session decision.
abstract final class AppRouter {
  static GoRouter create(TokenStorage tokenStorage) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: (context, state) async {
        final loggedIn = await tokenStorage.hasTokens;
        final location = state.matchedLocation;
        final onAuthScreen = location == AppRoutes.login ||
            location == AppRoutes.register ||
            location == AppRoutes.splash;

        if (!loggedIn && !onAuthScreen) return AppRoutes.login;
        if (loggedIn && onAuthScreen && location != AppRoutes.splash) {
          return AppRoutes.chats;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const _PlaceholderScreen(
            titleOf: _Title.appTitle,
          ),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const _PlaceholderScreen(
            titleOf: _Title.login,
          ),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const _PlaceholderScreen(
            titleOf: _Title.register,
          ),
        ),
        GoRoute(
          path: AppRoutes.chats,
          builder: (context, state) => const _PlaceholderScreen(
            titleOf: _Title.chats,
          ),
          routes: [
            GoRoute(
              path: 'friend-requests',
              builder: (context, state) => const _PlaceholderScreen(
                titleOf: _Title.friendRequests,
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) => const _PlaceholderScreen(
            titleOf: _Title.settings,
          ),
        ),
        GoRoute(
          path: AppRoutes.conversation,
          builder: (context, state) => const _PlaceholderScreen(
            titleOf: _Title.conversation,
          ),
        ),
      ],
    );
  }
}

enum _Title {
  appTitle,
  login,
  register,
  chats,
  friendRequests,
  settings,
  conversation,
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.titleOf});

  final _Title titleOf;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = switch (titleOf) {
      _Title.appTitle => l10n.appTitle,
      _Title.login => l10n.login,
      _Title.register => l10n.register,
      _Title.chats => l10n.chats,
      _Title.friendRequests => l10n.friendRequests,
      _Title.settings => l10n.settings,
      _Title.conversation => l10n.conversation,
    };

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}
