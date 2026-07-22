import 'package:chat_app/features/conversation/domain/entities/message.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_dto.g.dart';

@JsonSerializable()
class MessageDto {
  const MessageDto({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdAt,
    required this.status,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);

  final String id;
  final String content;
  final String senderId;
  final DateTime createdAt;

  /// `SENT` or `READ` on the wire.
  final String status;

  Message toEntity() => Message(
        id: id,
        content: content,
        senderId: senderId,
        createdAt: createdAt,
        status: status == 'READ' ? MessageStatus.read : MessageStatus.sent,
      );
}

@JsonSerializable()
class MessagePageDto {
  const MessagePageDto({required this.messages, this.nextCursor});

  factory MessagePageDto.fromJson(Map<String, dynamic> json) =>
      _$MessagePageDtoFromJson(json);

  final List<MessageDto> messages;
  final String? nextCursor;

  MessagePage toEntity() => MessagePage(
        messages: messages.map((dto) => dto.toEntity()).toList(),
        nextCursor: nextCursor,
      );
}

@JsonSerializable(createFactory: false)
class SendMessageBodyDto {
  const SendMessageBodyDto({required this.content});

  final String content;

  Map<String, dynamic> toJson() => _$SendMessageBodyDtoToJson(this);
}
