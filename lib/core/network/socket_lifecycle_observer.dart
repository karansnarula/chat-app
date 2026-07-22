import 'dart:async';

import 'package:chat_app/core/network/socket_service.dart';
import 'package:chat_app/core/storage/token_storage.dart';
import 'package:flutter/widgets.dart';

/// Closes the socket while the app is backgrounded and reopens it on
/// resume.
///
/// This is deliberate rather than an optimisation: the backend only sends
/// a push notification when the recipient has no live socket, so holding
/// the connection open in the background would silence notifications.
class SocketLifecycleObserver extends WidgetsBindingObserver {
  SocketLifecycleObserver(this._socketService, this._tokenStorage);

  final SocketService _socketService;
  final TokenStorage _tokenStorage;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_reconnectIfSignedIn());
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _socketService.disconnect();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _reconnectIfSignedIn() async {
    if (await _tokenStorage.hasTokens) await _socketService.connect();
  }
}
