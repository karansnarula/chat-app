import 'package:json_annotation/json_annotation.dart';

part 'fcm_token_dto.g.dart';

@JsonSerializable(createFactory: false)
class FcmTokenDto {
  const FcmTokenDto({required this.fcmToken});

  final String fcmToken;

  Map<String, dynamic> toJson() => _$FcmTokenDtoToJson(this);
}
