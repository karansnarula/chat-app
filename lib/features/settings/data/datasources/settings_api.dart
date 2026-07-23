import 'package:chat_app/features/settings/data/models/update_profile_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'settings_api.g.dart';

@RestApi()
// ignore: one_member_abstracts — grows with future profile fields
abstract class SettingsApi {
  factory SettingsApi(Dio dio) = _SettingsApi;

  @PATCH('/users/me')
  Future<ProfileDto> updateDisplayName(@Body() UpdateProfileDto body);
}
