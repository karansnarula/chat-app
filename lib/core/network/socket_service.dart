import 'dart:async';

import 'package:chat_app/core/constants/api_constants.dart';
import 'package:chat_app/core/network/socket_events.dart';
import 'package:chat_app/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

enum SocketStatus { disconnected, connecting, connected }

/// Owns the app's single socket.io connection.
///
/// The socket is receive-only: sending goes over REST so a message never
/// depends on connection health. Listeners subscribe to the typed streams
/// and are unaffected by connects, drops, and reconnects.
@lazySingleton
class SocketService {
  SocketService(this._tokenStorage, this._dio);

  final TokenStorage _tokenStorage;
  final Dio _dio;

  io.Socket? _socket;

  final _messages = StreamController<IncomingMessage>.broadcast();
  final _readReceipts = StreamController<ReadReceipt>.broadcast();
  final _friendRequests = StreamController<void>.broadcast();
  final _status = StreamController<SocketStatus>.broadcast();

  SocketStatus _currentStatus = SocketStatus.disconnected;

  Stream<IncomingMessage> get messages => _messages.stream;

  Stream<ReadReceipt> get readReceipts => _readReceipts.stream;

  Stream<void> get friendRequests => _friendRequests.stream;

  Stream<SocketStatus> get status => _status.stream;

  SocketStatus get currentStatus => _currentStatus;

  /// Emits after a drop-and-recover so listeners can refetch what they
  /// missed; the server does not replay events.
  Stream<void> get reconnections =>
      _status.stream.where((status) => status == SocketStatus.connected);

  Future<void> connect() async {
    if (_socket != null) return;
    if (!await _tokenStorage.hasTokens) return;

    _emitStatus(SocketStatus.connecting);

    // The gateway verifies the access token once, at connect time, and
    // drops the connection if it has expired — unlike REST calls, which
    // the interceptor retries after refreshing. Touching an authenticated
    // endpoint first lets that interceptor renew the token, so the socket
    // always opens with a valid one.
    if (!await _ensureFreshToken()) {
      _emitStatus(SocketStatus.disconnected);
      return;
    }

    final token = await _tokenStorage.readAccessToken();
    if (token == null) {
      _emitStatus(SocketStatus.disconnected);
      return;
    }

    _socket = io.io(
      ApiConstants.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          // socket_io_client caches one manager per URL, so a failed
          // attempt is replayed for every later connect to the same host.
          // Forcing a new manager keeps reconnects independent.
          .enableForceNew()
          .enableReconnection()
          .setReconnectionDelay(AppSocketConfig.reconnectDelayMs)
          .setReconnectionDelayMax(AppSocketConfig.reconnectDelayMaxMs)
          .build(),
    )
      ..onConnect((_) => _emitStatus(SocketStatus.connected))
      ..onDisconnect((_) => _emitStatus(SocketStatus.disconnected))
      ..onConnectError((error) => _logSocket('connect error', error))
      ..on(SocketEvents.messageNew, _handleMessage)
      ..on(SocketEvents.messageRead, _handleReadReceipt)
      ..on(SocketEvents.friendRequest, (_) => _friendRequests.add(null));
  }

  /// Called on logout and when the app is backgrounded — the backend only
  /// sends a push notification while the recipient has no live socket.
  void disconnect() {
    _socket
      ?..clearListeners()
      ..dispose();
    _socket = null;
    _emitStatus(SocketStatus.disconnected);
  }

  /// Reconnects with the current token, e.g. after a refresh.
  Future<void> reconnect() async {
    disconnect();
    await connect();
  }

  Future<bool> _ensureFreshToken() async {
    try {
      await _dio.get<dynamic>(ApiConstants.mePath);
      return true;
    } on DioException catch (error) {
      _logSocket('token refresh failed', error.message);
      return false;
    }
  }

  void _handleMessage(dynamic payload) {
    final json = _asJson(payload);
    if (json == null) return;
    final message = IncomingMessage.tryParse(json);
    if (message != null) _messages.add(message);
  }

  void _handleReadReceipt(dynamic payload) {
    final json = _asJson(payload);
    if (json == null) return;
    final receipt = ReadReceipt.tryParse(json);
    if (receipt != null) _readReceipts.add(receipt);
  }

  Map<String, dynamic>? _asJson(dynamic payload) =>
      payload is Map ? Map<String, dynamic>.from(payload) : null;

  void _emitStatus(SocketStatus status) {
    _currentStatus = status;
    if (!_status.isClosed) _status.add(status);
  }

  void _logSocket(String label, Object? detail) {
    if (kDebugMode) debugPrint('Socket $label: $detail');
  }

  @disposeMethod
  Future<void> dispose() async {
    disconnect();
    await _messages.close();
    await _readReceipts.close();
    await _friendRequests.close();
    await _status.close();
  }
}

abstract final class AppSocketConfig {
  static const int reconnectDelayMs = 1000;
  static const int reconnectDelayMaxMs = 10000;
}
