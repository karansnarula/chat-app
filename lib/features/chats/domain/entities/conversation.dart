import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.otherUser,
    required this.unreadCount,
    this.lastMessage,
  });

  final String id;
  final ConversationUser otherUser;
  final int unreadCount;
  final LastMessage? lastMessage;

  bool get hasUnread => unreadCount > 0;

  @override
  List<Object?> get props => [id, otherUser, unreadCount, lastMessage];
}

class ConversationUser extends Equatable {
  const ConversationUser({
    required this.id,
    required this.displayName,
    required this.email,
  });

  final String id;
  final String displayName;
  final String email;

  /// First letter of the display name, used for the avatar.
  String get initial =>
      displayName.trim().isEmpty ? '?' : displayName.trim()[0].toUpperCase();

  @override
  List<Object?> get props => [id, displayName, email];
}

class LastMessage extends Equatable {
  const LastMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdAt,
  });

  final String id;
  final String content;
  final String senderId;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, content, senderId, createdAt];
}
