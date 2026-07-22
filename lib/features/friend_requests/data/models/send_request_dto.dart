import 'package:json_annotation/json_annotation.dart';

part 'send_request_dto.g.dart';

@JsonSerializable(createFactory: false)
class SendRequestDto {
  const SendRequestDto({required this.email});

  final String email;

  Map<String, dynamic> toJson() => _$SendRequestDtoToJson(this);
}
