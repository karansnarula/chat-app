import 'package:chat_app/features/notifications/data/models/fcm_token_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'notifications_api.g.dart';

@RestApi()
// ignore: one_member_abstracts — grows with future notification settings
abstract class NotificationsApi {
  factory NotificationsApi(Dio dio) = _NotificationsApi;

  @PATCH('/users/me/fcm-token')
  Future<void> registerFcmToken(@Body() FcmTokenDto body);
}
