import 'package:dio/dio.dart';

/// App-level failures thrown by the data layer and rendered by blocs.
sealed class AppException implements Exception {
  const AppException(this.message);

  /// Maps a [DioException] to the matching [AppException].
  factory AppException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode ?? 0;
        final message = _messageFromResponse(error.response);
        if (status == 401) {
          return UnauthorizedException(message);
        }
        return ServerException(message, statusCode: status);
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return UnknownException(error.message ?? 'Unexpected error');
    }
  }

  /// Human-readable fallback; screens prefer localized copy keyed on the
  /// exception type.
  final String message;

  static String _messageFromResponse(Response<dynamic>? response) {
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String) return message;
      if (message is List && message.isNotEmpty) {
        return message.first.toString();
      }
    }
    return 'Something went wrong';
  }

  @override
  String toString() => 'AppException: $message';
}

final class NetworkException extends AppException {
  const NetworkException() : super('No internet connection');
}

final class ServerException extends AppException {
  const ServerException(super.message, {required this.statusCode});

  final int statusCode;
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}

final class UnknownException extends AppException {
  const UnknownException(super.message);
}
