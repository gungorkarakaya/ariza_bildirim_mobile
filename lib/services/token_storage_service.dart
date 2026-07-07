import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _rememberedUsernameKey = 'remembered_username';
  static const String _rememberedPasswordKey = 'remembered_password';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveAccessToken(String accessToken) async {
    await _storage.write(
      key: _accessTokenKey,
      value: accessToken,
    );
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(
      key: _accessTokenKey,
    );
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(
      key: _accessTokenKey,
    );
  }

  Future<void> saveRememberedUsername(String username) async {
    await _storage.write(
      key: _rememberedUsernameKey,
      value: username,
    );
  }

  Future<String?> getRememberedUsername() async {
    return await _storage.read(
      key: _rememberedUsernameKey,
    );
  }

  Future<void> clearRememberedUsername() async {
    await _storage.delete(
      key: _rememberedUsernameKey,
    );
  }

  Future<void> saveRememberedPassword(String password) async {
    await _storage.write(
      key: _rememberedPasswordKey,
      value: password,
    );
  }

  Future<String?> getRememberedPassword() async {
    return await _storage.read(
      key: _rememberedPasswordKey,
    );
  }

  Future<void> clearRememberedPassword() async {
    await _storage.delete(
      key: _rememberedPasswordKey,
    );
  }

  Future<void> clearRememberedLogin() async {
    await clearRememberedUsername();
    await clearRememberedPassword();
  }
}