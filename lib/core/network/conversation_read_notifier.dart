import 'dart:async';

import 'package:injectable/injectable.dart';

/// Signals that the signed-in user read a conversation.
///
/// Marking a thread read is a REST call the backend does not echo back
/// over the socket, so the chats list has no other way to learn its own
/// unread counts changed. The conversation repository publishes here; the
/// chats repository folds this into its refresh trigger.
@lazySingleton
class ConversationReadNotifier {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get onRead => _controller.stream;

  void notifyRead() => _controller.add(null);

  @disposeMethod
  Future<void> dispose() => _controller.close();
}
