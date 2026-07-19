import 'package:chat_app/core/constants/api_constants.dart';
import 'package:chat_app/core/network/session_manager.dart';
import 'package:chat_app/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Attaches the access token to outgoing requests and transparently
/// refreshes it on 401.
///
/// Extends [QueuedInterceptor] so concurrent 401s wait for a single
/// refresh instead of racing. Refresh calls go through a bare [Dio]
/// (no interceptors) to avoid recursion. If refresh fails, tokens are
/// cleared and [SessionManager.expireSession] fires.
@injectable
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._tokenStorage, this._sessionManager, {Dio? refreshDio})
      : _refreshDio =
            refreshDio ?? Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  final TokenStorage _tokenStorage;
  final SessionManager _sessionManager;
  final Dio _refreshDio;

  static const _retriedKey = 'auth_retried';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;

    if (response?.statusCode != 401 || alreadyRetried) {
      handler.next(err);
      return;
    }

    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) {
      _sessionManager.expireSession();
      handler.next(err);
      return;
    }

    try {
      final refreshResponse = await _refreshDio.post<Map<String, dynamic>>(
        ApiConstants.refreshPath,
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );
      final data = refreshResponse.data!;
      final newAccessToken = data['accessToken'] as String;
      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: data['refreshToken'] as String,
      );

      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newAccessToken'
        ..extra[_retriedKey] = true;
      final retryResponse = await _refreshDio.fetch<dynamic>(retryOptions);
      handler.resolve(retryResponse);
    } on DioException {
      await _tokenStorage.clear();
      _sessionManager.expireSession();
      handler.next(err);
    }
  }
}
