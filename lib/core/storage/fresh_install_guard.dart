import 'package:chat_app/core/storage/token_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clears stored credentials after a reinstall.
///
/// iOS keeps Keychain entries when an app is deleted, so a fresh install
/// would otherwise find the previous user's tokens and sign straight back
/// in. Preferences *are* cleared on uninstall, so a missing flag there
/// means this is a fresh install and the Keychain is stale.
@lazySingleton
class FreshInstallGuard {
  const FreshInstallGuard(this._preferences, this._tokenStorage);

  final SharedPreferences _preferences;
  final TokenStorage _tokenStorage;

  static const _installedKey = 'installed';

  Future<void> clearCredentialsIfReinstalled() async {
    if (_preferences.getBool(_installedKey) ?? false) return;

    await _tokenStorage.clear();
    await _preferences.setBool(_installedKey, true);
  }
}
