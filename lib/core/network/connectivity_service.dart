import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

/// Reports whether the device has a network interface at all.
///
/// This is a hint, not proof of reachability: a connected Wi-Fi network can
/// still fail to reach the backend. Request failures are still surfaced as
/// exceptions; this only lets the UI explain an obvious offline state
/// before a request is even attempted.
@lazySingleton
class ConnectivityService {
  ConnectivityService(this._connectivity);

  final Connectivity _connectivity;

  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(_hasConnection);

  Future<bool> get isOnline async =>
      _hasConnection(await _connectivity.checkConnectivity());

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
}
