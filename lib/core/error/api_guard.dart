import 'package:chat_app/core/error/app_exception.dart';
import 'package:dio/dio.dart';

/// Runs [request] and rethrows transport failures as [AppException]s so
/// repositories never leak Dio types into the domain.
Future<T> guard<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (error) {
    throw AppException.fromDio(error);
  }
}
