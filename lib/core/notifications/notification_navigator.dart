import 'dart:async';

import 'package:chat_app/core/notifications/notification_service.dart';
import 'package:chat_app/core/router/app_routes.dart';
import 'package:chat_app/core/storage/token_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Opens the conversation behind a tapped notification.
///
/// Kept out of [NotificationService] so that service stays free of routing;
/// this widget owns the navigation and the cold-start case, where a tap
/// launches the app and the route can only be pushed once the router has
/// mounted.
class NotificationNavigator extends StatefulWidget {
  const NotificationNavigator({
    required this.notificationService,
    required this.router,
    required this.tokenStorage,
    required this.child,
    super.key,
  });

  final NotificationService notificationService;
  final GoRouter router;
  final TokenStorage tokenStorage;
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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(_openLaunchTarget()),
    );
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
    // A signed-out user would be redirected to login anyway, and pushing
    // first would leave the conversation stranded in the back stack.
    if (!await widget.tokenStorage.hasTokens) return;

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
