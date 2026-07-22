import 'package:chat_app/core/error/app_exception.dart';
import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/core/network/session_manager.dart';
import 'package:chat_app/core/storage/token_storage.dart';
import 'package:chat_app/features/auth/data/datasources/auth_api.dart';
import 'package:chat_app/features/auth/data/models/auth_response_dto.dart';
import 'package:chat_app/features/auth/data/models/login_request_dto.dart';
import 'package:chat_app/features/auth/data/models/user_dto.dart';
import 'package:chat_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:chat_app/features/auth/domain/entities/auth_user.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthApi extends Mock implements AuthApi {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  const response = AuthResponseDto(
    user: UserDto(id: 'u1', email: 'k@n.com', displayName: 'Karan'),
    accessToken: 'access',
    refreshToken: 'refresh',
  );

  late MockAuthApi api;
  late MockTokenStorage tokenStorage;
  late SessionManager sessionManager;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      const LoginRequestDto(email: '', password: ''),
    );
  });

  setUp(() {
    api = MockAuthApi();
    tokenStorage = MockTokenStorage();
    sessionManager = SessionManager();
    repository = AuthRepositoryImpl(api, tokenStorage, sessionManager);
  });

  tearDown(() => sessionManager.dispose());

  test('login saves tokens and returns Success with the user entity',
      () async {
    when(() => api.login(any())).thenAnswer((_) async => response);
    when(
      () => tokenStorage.saveTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((_) async {});
    when(() => tokenStorage.saveUserId(any())).thenAnswer((_) async {});

    final result = await repository.login(
      email: 'k@n.com',
      password: 'password1',
    );

    final user = (result as Success<AuthUser>).value;
    expect(user.id, 'u1');
    expect(user.displayName, 'Karan');
    verify(
      () => tokenStorage.saveTokens(
        accessToken: 'access',
        refreshToken: 'refresh',
      ),
    ).called(1);
    verify(() => tokenStorage.saveUserId('u1')).called(1);
  });

  test('login returns Failure with the mapped AppException', () async {
    when(() => api.login(any())).thenThrow(
      DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 401,
          data: {'message': 'Invalid credentials'},
        ),
      ),
    );

    final result = await repository.login(
      email: 'k@n.com',
      password: 'nope',
    );

    final exception = (result as Failure).exception;
    expect(exception, isA<UnauthorizedException>());
    expect(exception.message, 'Invalid credentials');
    verifyNever(
      () => tokenStorage.saveTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    );
  });

  test('logout clears tokens even when the server call fails', () async {
    when(() => api.logout()).thenThrow(
      DioException(requestOptions: RequestOptions()),
    );
    when(() => tokenStorage.clear()).thenAnswer((_) async {});

    await repository.logout();

    verify(() => tokenStorage.clear()).called(1);
  });
}
