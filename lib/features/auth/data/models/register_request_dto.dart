import 'package:json_annotation/json_annotation.dart';

part 'register_request_dto.g.dart';

@JsonSerializable(createFactory: false)
class RegisterRequestDto {
  const RegisterRequestDto({
    required this.email,
    required this.password,
    required this.displayName,
  });

  final String email;
  final String password;
  final String displayName;

  Map<String, dynamic> toJson() => _$RegisterRequestDtoToJson(this);
}
