import 'package:json_annotation/json_annotation.dart';

part 'respond_request_dto.g.dart';

@JsonSerializable(createFactory: false)
class RespondRequestDto {
  const RespondRequestDto({required this.action});

  /// Either `accept` or `decline`, matching the backend contract.
  final String action;

  Map<String, dynamic> toJson() => _$RespondRequestDtoToJson(this);
}
