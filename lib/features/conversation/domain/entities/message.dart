import 'package:equatable/equatable.dart';

enum MessageStatus { sending, sent, read, failed }

class Message extends Equatable {
  const Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String content;
  final String senderId;
  final DateTime createdAt;
  final MessageStatus status;

  Message copyWith({String? id, MessageStatus? status}) => Message(
        id: id ?? this.id,
        content: content,
        senderId: senderId,
        createdAt: createdAt,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [id, content, senderId, createdAt, status];
}

/// A page of history plus the cursor for the next, older page.
class MessagePage extends Equatable {
  const MessagePage({required this.messages, this.nextCursor});

  final List<Message> messages;
  final String? nextCursor;

  bool get hasMore => nextCursor != null;

  @override
  List<Object?> get props => [messages, nextCursor];
}
