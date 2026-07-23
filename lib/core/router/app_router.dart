import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/core/router/app_routes.dart';
import 'package:chat_app/core/router/router_refresh_stream.dart';
import 'package:chat_app/core/widgets/app_shell.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/auth/presentation/screens/login_screen.dart';
import 'package:chat_app/features/auth/presentation/screens/register_screen.dart';
import 'package:chat_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:chat_app/features/chats/presentation/screens/chats_screen.dart';
import 'package:chat_app/features/conversation/presentation/screens/conversation_screen.dart';
import 'package:chat_app/features/friend_requests/presentation/screens/friend_requests_screen.dart';
import 'package:chat_app/features/settings/presentation/screens/settings_screen.dart';
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
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.chats,
                  builder: (context, state) => const ChatsScreen(),
                  routes: [
                    GoRoute(
                      path: 'friend-requests',
                      builder: (context, state) =>
                          const FriendRequestsScreen(),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.settings,
                  builder: (context, state) => const SettingsScreen(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.conversation,
          builder: (context, state) => ConversationScreen(
            conversationId: state.pathParameters['id']!,
            title: state.uri
                    .queryParameters[AppRoutes.conversationTitleParam] ??
                AppLocalizations.of(context).conversation,
          ),
        ),
      ],
    );
  }
}
