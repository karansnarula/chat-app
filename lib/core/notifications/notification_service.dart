import 'dart:async';
import 'dart:convert';

import 'package:chat_app/core/constants/app_strings.dart';
import 'package:chat_app/core/network/socket_events.dart';
import 'package:chat_app/core/network/socket_service.dart';
import 'package:chat_app/core/notifications/active_conversation.dart';
import 'package:chat_app/features/notifications/domain/usecases/register_push_token_use_case.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

/// Runs when a push arrives while the app is terminated or backgrounded.
///
/// Android renders the tray notification from the payload itself, so this
/// only needs to exist for the isolate to start cleanly.
@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {}

/// Coordinates push and in-app notifications.
///
/// The two paths never overlap, by design: the backend only pushes when
/// the recipient has no live socket, and the socket is closed while the
/// app is backgrounded. So FCM covers backgrounded/terminated, and the
/// socket covers foreground — where a local notification is raised only
/// for threads the user is not currently reading.
@lazySingleton
class NotificationService {
  NotificationService(
    this._registerPushToken,
    this._socketService,
    this._activeConversation,
  );

  final RegisterPushTokenUseCase _registerPushToken;
  final SocketService _socketService;
  final ActiveConversation _activeConversation;

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _conversationTaps = StreamController<NotificationTarget>.broadcast();

  StreamSubscription<IncomingMessage>? _messageSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  static const _channelId = 'messages';
  static const _payloadConversationId = 'conversationId';
  static const _payloadTitle = 'title';

  /// Conversations the user asked to open by tapping a notification.
  Stream<NotificationTarget> get conversationTaps => _conversationTaps.stream;

  /// Set up channels and listeners. Safe to call before sign-in; nothing
  /// is registered with the backend until [registerToken].
  Future<void> initialise() async {
    await _configureLocalNotifications();

    FirebaseMessaging.onMessage.listen(_onForegroundPush);
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpenedApp);

    _messageSubscription = _socketService.messages.listen(_onSocketMessage);
  }

  /// The notification that launched a terminated app, if any.
  Future<NotificationTarget?> initialTarget() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    return message == null ? null : _targetFromRemote(message);
  }

  /// Requests permission and sends the device token to the backend. Call
  /// after sign-in; failures are non-fatal — the app simply gets no pushes.
  Future<void> registerToken() async {
    try {
      await FirebaseMessaging.instance.requestPermission();

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _registerPushToken(token);

      await _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
          .listen((token) => unawaited(_registerPushToken(token)));
    } on Exception catch (error) {
      // No APNs key on iOS, no Play Services, permission denied, and so on.
      _log('push registration skipped: $error');
    }
  }

  Future<void> _configureLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            AppStrings.messagesChannelName,
            importance: Importance.high,
          ),
        );
  }

  /// A push while the app is in the foreground is unusual — the socket
  /// would normally have delivered it — but handle it for completeness.
  void _onForegroundPush(RemoteMessage message) {
    final conversationId = message.data[_payloadConversationId] as String?;
    if (conversationId == null) return;
    if (_activeConversation.isActive(conversationId)) return;

    unawaited(
      _show(
        title: message.notification?.title ?? AppStrings.appName,
        body: message.notification?.body ?? '',
        conversationId: conversationId,
      ),
    );
  }

  void _onSocketMessage(IncomingMessage message) {
    if (_activeConversation.isActive(message.conversationId)) return;

    unawaited(
      _show(
        title: message.senderName ?? AppStrings.appName,
        body: message.content,
        conversationId: message.conversationId,
      ),
    );
  }

  Future<void> _show({
    required String title,
    required String body,
    required String conversationId,
  }) async {
    await _localNotifications.show(
      // Same id per conversation, so a thread replaces its own notification
      // instead of stacking one per message.
      id: conversationId.hashCode,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          AppStrings.messagesChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode({
        _payloadConversationId: conversationId,
        _payloadTitle: title,
      }),
    );
  }

  void _onLocalNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    final data = jsonDecode(payload) as Map<String, dynamic>;
    final conversationId = data[_payloadConversationId] as String?;
    if (conversationId == null) return;

    _conversationTaps.add(
      NotificationTarget(
        conversationId: conversationId,
        title: data[_payloadTitle] as String? ?? AppStrings.appName,
      ),
    );
  }

  void _onNotificationOpenedApp(RemoteMessage message) {
    final target = _targetFromRemote(message);
    if (target != null) _conversationTaps.add(target);
  }

  NotificationTarget? _targetFromRemote(RemoteMessage message) {
    final conversationId = message.data[_payloadConversationId] as String?;
    if (conversationId == null) return null;

    return NotificationTarget(
      conversationId: conversationId,
      title: message.notification?.title ?? AppStrings.appName,
    );
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('Notifications: $message');
  }

  @disposeMethod
  Future<void> dispose() async {
    await _messageSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();
    await _conversationTaps.close();
  }
}

/// A conversation the user wants opened, from tapping a notification.
class NotificationTarget {
  const NotificationTarget({
    required this.conversationId,
    required this.title,
  });

  final String conversationId;
  final String title;
}
