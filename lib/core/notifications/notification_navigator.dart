import 'dart:async';

import 'package:chat_app/core/notifications/notification_service.dart';
import 'package:chat_app/core/router/app_routes.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Opens the conversation behind a tapped notification.
///
/// Kept out of [NotificationService] so that service stays free of routing;
/// this widget owns the navigation and the cold-start case, where a tap
/// launches the app and the route can only be pushed once the session has
/// been restored.
class NotificationNavigator extends StatefulWidget {
  const NotificationNavigator({
    required this.notificationService,
    required this.router,
    required this.authBloc,
    required this.child,
    super.key,
  });

  final NotificationService notificationService;
  final GoRouter router;
  final AuthBloc authBloc;
  final Widget child;

  @override
  State<NotificationNavigator> createState() => _NotificationNavigatorState();
}

class _NotificationNavigatorState extends State<NotificationNavigator> {
  StreamSubscription<NotificationTarget>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription =
        widget.notificationService.conversationTaps.listen(_open);
    unawaited(_openLaunchTarget());
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  /// Handles a tap that launched a terminated app.
  Future<void> _openLaunchTarget() async {
    final target = await widget.notificationService.initialTarget();
    if (target != null) await _open(target);
  }

  Future<void> _open(NotificationTarget target) async {
    // On a cold start the session is still being restored, and the router
    // sends every route to the splash screen until it settles — pushing
    // before then would be silently swallowed.
    if (widget.authBloc.state.status == AuthStatus.unknown) {
      await widget.authBloc.stream.firstWhere(
        (state) => state.status != AuthStatus.unknown,
      );
    }

    // A signed-out user would be redirected to login anyway, and pushing
    // first would leave the conversation stranded in the back stack.
    if (widget.authBloc.state.status != AuthStatus.authenticated) return;

    unawaited(
      widget.router.push(
        Uri(
          path: AppRoutes.conversationWithId(target.conversationId),
          queryParameters: {AppRoutes.conversationTitleParam: target.title},
        ).toString(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
