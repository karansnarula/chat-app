import 'package:chat_app/core/storage/token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockSecureStorage secureStorage;
  late TokenStorage tokenStorage;

  setUp(() {
    secureStorage = MockSecureStorage();
    tokenStorage = TokenStorage(secureStorage);
  });

  test('saveTokens writes both tokens', () async {
    when(
      () => secureStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});

    await tokenStorage.saveTokens(accessToken: 'a', refreshToken: 'r');

    verify(() => secureStorage.write(key: 'access_token', value: 'a'))
        .called(1);
    verify(() => secureStorage.write(key: 'refresh_token', value: 'r'))
        .called(1);
  });

  test('hasTokens reflects presence of a refresh token', () async {
    when(() => secureStorage.read(key: 'refresh_token'))
        .thenAnswer((_) async => 'r');
    expect(await tokenStorage.hasTokens, isTrue);

    when(() => secureStorage.read(key: 'refresh_token'))
        .thenAnswer((_) async => null);
    expect(await tokenStorage.hasTokens, isFalse);
  });

  test('clear deletes both tokens', () async {
    when(() => secureStorage.delete(key: any(named: 'key')))
        .thenAnswer((_) async {});

    await tokenStorage.clear();

    verify(() => secureStorage.delete(key: 'access_token')).called(1);
    verify(() => secureStorage.delete(key: 'refresh_token')).called(1);
  });
}
