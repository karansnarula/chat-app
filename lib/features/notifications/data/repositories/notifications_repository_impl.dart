import 'package:chat_app/core/error/api_guard.dart';
import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/notifications/data/datasources/notifications_api.dart';
import 'package:chat_app/features/notifications/data/models/fcm_token_dto.dart';
import 'package:chat_app/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: NotificationsRepository)
class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._api);

  final NotificationsApi _api;

  @override
  Future<Result<void>> registerPushToken(String token) =>
      guard(() => _api.registerFcmToken(FcmTokenDto(fcmToken: token)));
}
