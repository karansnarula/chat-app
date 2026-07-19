import 'dart:async';

import 'package:injectable/injectable.dart';

/// Broadcasts session expiry (refresh failed) so the auth layer can force
/// a logout without the network layer knowing about blocs or navigation.
@lazySingleton
class SessionManager {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get onSessionExpired => _controller.stream;

  void expireSession() => _controller.add(null);

  @disposeMethod
  Future<void> dispose() => _controller.close();
}
