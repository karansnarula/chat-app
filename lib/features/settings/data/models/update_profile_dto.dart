import 'package:json_annotation/json_annotation.dart';

part 'update_profile_dto.g.dart';

@JsonSerializable(createFactory: false)
class UpdateProfileDto {
  const UpdateProfileDto({required this.displayName});

  final String displayName;

  Map<String, dynamic> toJson() => _$UpdateProfileDtoToJson(this);
}

@JsonSerializable(createToJson: false)
class ProfileDto {
  const ProfileDto({
    required this.id,
    required this.email,
    required this.displayName,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileDtoFromJson(json);

  final String id;
  final String email;
  final String displayName;
}
