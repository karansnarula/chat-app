import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/core/router/app_routes.dart';
import 'package:chat_app/core/router/router_refresh_stream.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/auth/presentation/screens/login_screen.dart';
import 'package:chat_app/features/auth/presentation/screens/register_screen.dart';
import 'package:chat_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Auth-driven routing: the redirect derives everything from
/// [AuthBloc.state] and re-evaluates on every bloc emission via
/// `refreshListenable`.
abstract final class AppRouter {
  static GoRouter create(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: RouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final status = authBloc.state.status;
        final location = state.matchedLocation;
        final onAuthScreen = location == AppRoutes.login ||
            location == AppRoutes.register;

        return switch (status) {
          AuthStatus.unknown =>
            location == AppRoutes.splash ? null : AppRoutes.splash,
          AuthStatus.unauthenticated =>
            onAuthScreen ? null : AppRoutes.login,
          AuthStatus.authenticated =>
            (onAuthScreen || location == AppRoutes.splash)
                ? AppRoutes.chats
                : null,
        };
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterScreen(),
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

enum _Title { chats, friendRequests, settings, conversation }

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.titleOf});

  final _Title titleOf;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = switch (titleOf) {
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
