import 'package:chat_app/core/error/result.dart';

// ignore: one_member_abstracts — grows with future notification settings
abstract interface class NotificationsRepository {
  Future<Result<void>> registerPushToken(String token);
}
