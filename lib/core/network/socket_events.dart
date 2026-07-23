/// Socket.io event names, matching the backend gateway.
abstract final class SocketEvents {
  static const String messageSend = 'message:send';
  static const String messageNew = 'message:new';
  static const String messageRead = 'message:read';
  static const String friendRequest = 'friend:request';
}

/// A message pushed by the server while the socket is connected.
class IncomingMessage {
  const IncomingMessage({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.senderId,
    required this.createdAt,
    this.senderName,
  });

  /// Tolerant of missing fields: a malformed payload must not crash the
  /// stream that every listener depends on.
  static IncomingMessage? tryParse(Map<String, dynamic> json) {
    final id = json['id'];
    final conversationId = json['conversationId'];
    final content = json['content'];
    final senderId = json['senderId'];
    if (id is! String ||
        conversationId is! String ||
        content is! String ||
        senderId is! String) {
      return null;
    }

    final sender = json['sender'];

    return IncomingMessage(
      id: id,
      conversationId: conversationId,
      content: content,
      senderId: senderId,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ??
              DateTime.now(),
      senderName:
          sender is Map ? sender['displayName'] as String? : null,
    );
  }

  final String id;
  final String conversationId;
  final String content;
  final String senderId;
  final DateTime createdAt;

  /// Present on socket pushes; used as the notification title.
  final String? senderName;
}

/// Notification that the other participant read the thread.
class ReadReceipt {
  const ReadReceipt({required this.conversationId, required this.readBy});

  static ReadReceipt? tryParse(Map<String, dynamic> json) {
    final conversationId = json['conversationId'];
    final readBy = json['readBy'];
    if (conversationId is! String || readBy is! String) return null;
    return ReadReceipt(conversationId: conversationId, readBy: readBy);
  }

  final String conversationId;
  final String readBy;
}
