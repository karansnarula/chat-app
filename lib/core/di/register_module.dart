import 'package:chat_app/core/network/auth_interceptor.dart';
import 'package:chat_app/core/network/dio_factory.dart';
import 'package:chat_app/core/router/app_router.dart';
import 'package:chat_app/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  Dio dio(AuthInterceptor authInterceptor) =>
      DioFactory.create(authInterceptor);

  @lazySingleton
  GoRouter router(TokenStorage tokenStorage) =>
      AppRouter.create(tokenStorage);
}
