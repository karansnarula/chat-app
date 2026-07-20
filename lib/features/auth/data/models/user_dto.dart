import 'package:chat_app/features/auth/domain/entities/auth_user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto {
  const UserDto({
    required this.id,
    required this.email,
    required this.displayName,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  final String id;
  final String email;
  final String displayName;

  AuthUser toEntity() =>
      AuthUser(id: id, email: email, displayName: displayName);
}
