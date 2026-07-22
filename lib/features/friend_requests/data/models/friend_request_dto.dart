import 'package:chat_app/features/friend_requests/domain/entities/friend_request.dart';
import 'package:json_annotation/json_annotation.dart';

part 'friend_request_dto.g.dart';

@JsonSerializable()
class FriendRequestDto {
  const FriendRequestDto({
    required this.id,
    required this.sender,
    required this.createdAt,
  });

  factory FriendRequestDto.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestDtoFromJson(json);

  final String id;
  final RequestSenderDto sender;
  final DateTime createdAt;

  FriendRequest toEntity() => FriendRequest(
        id: id,
        sender: sender.toEntity(),
        createdAt: createdAt,
      );
}

@JsonSerializable()
class RequestSenderDto {
  const RequestSenderDto({
    required this.id,
    required this.displayName,
    required this.email,
  });

  factory RequestSenderDto.fromJson(Map<String, dynamic> json) =>
      _$RequestSenderDtoFromJson(json);

  final String id;
  final String displayName;
  final String email;

  RequestSender toEntity() =>
      RequestSender(id: id, displayName: displayName, email: email);
}
