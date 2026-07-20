import 'package:chat_app/core/error/app_exception.dart';
import 'package:chat_app/core/error/result.dart';
import 'package:dio/dio.dart';

/// Runs [request] and captures failures as a typed [Result] so
/// repositories never leak Dio types into the domain.
Future<Result<T>> guard<T>(Future<T> Function() request) async {
  try {
    return Success(await request());
  } on DioException catch (error) {
    return Failure(AppException.fromDio(error));
  } on Exception catch (error) {
    return Failure(UnknownException(error.toString()));
  }
}
