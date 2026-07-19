import 'dart:convert';

import 'package:chat_app/core/network/auth_interceptor.dart';
import 'package:chat_app/core/network/session_manager.dart';
import 'package:chat_app/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTokenStorage extends Mock implements TokenStorage {}

class MockDio extends Mock implements Dio {}

class MockAdapter extends Mock implements HttpClientAdapter {}

void main() {
  late MockTokenStorage tokenStorage;
  late SessionManager sessionManager;
  late MockDio refreshDio;
  late MockAdapter adapter;
  late Dio dio;

  setUpAll(() {
    registerFallbackValue(RequestOptions());
  });

  setUp(() {
    tokenStorage = MockTokenStorage();
    sessionManager = SessionManager();
    refreshDio = MockDio();
    adapter = MockAdapter();
    dio = Dio(BaseOptions(validateStatus: (_) => true))
      ..httpClientAdapter = adapter
      ..interceptors.add(
        AuthInterceptor(tokenStorage, sessionManager, refreshDio: refreshDio),
      );
  });

  tearDown(() => sessionManager.dispose());

  void stubServerResponse(int statusCode, {String body = '{}'}) {
    when(() => adapter.fetch(any(), any(), any())).thenAnswer(
      (_) async => ResponseBody.fromString(
        body,
        statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
  }

  test('attaches bearer token to requests when one is stored', () async {
    when(() => tokenStorage.readAccessToken())
        .thenAnswer((_) async => 'access-1');
    stubServerResponse(200);

    await dio.get<dynamic>('/anything');

    final sent = verify(() => adapter.fetch(captureAny(), any(), any()))
        .captured
        .single as RequestOptions;
    expect(sent.headers['Authorization'], 'Bearer access-1');
  });

  test('sends no auth header when no token is stored', () async {
    when(() => tokenStorage.readAccessToken()).thenAnswer((_) async => null);
    stubServerResponse(200);

    await dio.get<dynamic>('/anything');

    final sent = verify(() => adapter.fetch(captureAny(), any(), any()))
        .captured
        .single as RequestOptions;
    expect(sent.headers.containsKey('Authorization'), isFalse);
  });

  group('on 401', () {
    setUp(() {
      dio.options.validateStatus = (status) => status == 200;
      when(() => tokenStorage.readAccessToken())
          .thenAnswer((_) async => 'stale');
      stubServerResponse(401);
    });

    test('refreshes tokens and retries the original request', () async {
      when(() => tokenStorage.readRefreshToken())
          .thenAnswer((_) async => 'refresh-1');
      when(
        () => tokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => refreshDio.post<Map<String, dynamic>>(
          any(),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          statusCode: 200,
          data: {'accessToken': 'access-2', 'refreshToken': 'refresh-2'},
        ),
      );
      when(() => refreshDio.fetch<dynamic>(any())).thenAnswer(
        (invocation) async => Response(
          requestOptions:
              invocation.positionalArguments.first as RequestOptions,
          statusCode: 200,
          data: jsonDecode('{"result": "retried"}'),
        ),
      );

      final response = await dio.get<dynamic>('/protected');

      expect(response.data, {'result': 'retried'});
      verify(
        () => tokenStorage.saveTokens(
          accessToken: 'access-2',
          refreshToken: 'refresh-2',
        ),
      ).called(1);
      final retried = verify(() => refreshDio.fetch<dynamic>(captureAny()))
          .captured
          .single as RequestOptions;
      expect(retried.headers['Authorization'], 'Bearer access-2');
    });

    test('expires session when no refresh token exists', () async {
      when(() => tokenStorage.readRefreshToken())
          .thenAnswer((_) async => null);

      final expired = expectLater(
        sessionManager.onSessionExpired,
        emits(anything),
      );
      await expectLater(
        dio.get<dynamic>('/protected'),
        throwsA(isA<DioException>()),
      );
      await expired;
    });

    test('clears tokens and expires session when refresh fails', () async {
      when(() => tokenStorage.readRefreshToken())
          .thenAnswer((_) async => 'refresh-1');
      when(() => tokenStorage.clear()).thenAnswer((_) async {});
      when(
        () => refreshDio.post<Map<String, dynamic>>(
          any(),
          options: any(named: 'options'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: 401,
          ),
        ),
      );

      final expired = expectLater(
        sessionManager.onSessionExpired,
        emits(anything),
      );
      await expectLater(
        dio.get<dynamic>('/protected'),
        throwsA(isA<DioException>()),
      );
      await expired;
      verify(() => tokenStorage.clear()).called(1);
    });
  });
}
