import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage(this._preferences);

  static const _tokenKey = 'auth.token';
  static const _usernameKey = 'auth.username';
  static const _mutedKey = 'settings.muted';

  final SharedPreferences _preferences;

  static Future<LocalStorage> create() async {
    return LocalStorage(await SharedPreferences.getInstance());
  }

  Future<void> saveToken(String token) async {
    await _preferences.setString(_tokenKey, token);
  }

  String? getToken() => _preferences.getString(_tokenKey);

  Future<void> saveUsername(String username) async {
    await _preferences.setString(_usernameKey, username);
  }

  String? getUsername() => _preferences.getString(_usernameKey);

  Future<void> setMuted(bool muted) async {
    await _preferences.setBool(_mutedKey, muted);
  }

  bool isMuted() => _preferences.getBool(_mutedKey) ?? false;

  Future<void> clearAuth() async {
    await Future.wait([
      _preferences.remove(_tokenKey),
      _preferences.remove(_usernameKey),
    ]);
  }
}
