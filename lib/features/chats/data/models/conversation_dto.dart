import 'package:chat_app/features/chats/domain/entities/conversation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'conversation_dto.g.dart';

@JsonSerializable()
class ConversationDto {
  const ConversationDto({
    required this.id,
    required this.otherUser,
    required this.unreadCount,
    this.lastMessage,
  });

  factory ConversationDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationDtoFromJson(json);

  final String id;
  final ConversationUserDto otherUser;
  final int unreadCount;
  final LastMessageDto? lastMessage;

  Conversation toEntity() => Conversation(
        id: id,
        otherUser: otherUser.toEntity(),
        unreadCount: unreadCount,
        lastMessage: lastMessage?.toEntity(),
      );
}

@JsonSerializable()
class ConversationUserDto {
  const ConversationUserDto({
    required this.id,
    required this.displayName,
    required this.email,
  });

  factory ConversationUserDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationUserDtoFromJson(json);

  final String id;
  final String displayName;
  final String email;

  ConversationUser toEntity() =>
      ConversationUser(id: id, displayName: displayName, email: email);
}

@JsonSerializable()
class LastMessageDto {
  const LastMessageDto({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdAt,
  });

  factory LastMessageDto.fromJson(Map<String, dynamic> json) =>
      _$LastMessageDtoFromJson(json);

  final String id;
  final String content;
  final String senderId;
  final DateTime createdAt;

  LastMessage toEntity() => LastMessage(
        id: id,
        content: content,
        senderId: senderId,
        createdAt: createdAt,
      );
}
