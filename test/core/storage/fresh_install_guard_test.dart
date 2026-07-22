import 'package:chat_app/core/storage/fresh_install_guard.dart';
import 'package:chat_app/core/storage/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockTokenStorage tokenStorage;

  setUp(() {
    tokenStorage = MockTokenStorage();
    when(tokenStorage.clear).thenAnswer((_) async {});
  });

  Future<FreshInstallGuard> buildGuard({required bool installedBefore}) async {
    SharedPreferences.setMockInitialValues(
      installedBefore ? {'installed': true} : {},
    );
    final preferences = await SharedPreferences.getInstance();
    return FreshInstallGuard(preferences, tokenStorage);
  }

  test('clears credentials left in the keychain by a previous install',
      () async {
    final guard = await buildGuard(installedBefore: false);

    await guard.clearCredentialsIfReinstalled();

    verify(tokenStorage.clear).called(1);
  });

  test('keeps the session on subsequent launches', () async {
    final guard = await buildGuard(installedBefore: true);

    await guard.clearCredentialsIfReinstalled();

    verifyNever(tokenStorage.clear);
  });

  test('only clears once, so a later launch keeps the new session', () async {
    final guard = await buildGuard(installedBefore: false);

    await guard.clearCredentialsIfReinstalled();
    await guard.clearCredentialsIfReinstalled();

    verify(tokenStorage.clear).called(1);
  });
}
