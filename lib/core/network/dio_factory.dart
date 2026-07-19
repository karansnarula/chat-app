import 'package:chat_app/core/constants/api_constants.dart';
import 'package:chat_app/core/network/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract final class DioFactory {
  static Dio create(AuthInterceptor authInterceptor) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
      ),
    )..interceptors.add(authInterceptor);

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    return dio;
  }
}
