import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _emailKey = 'email';

  final FlutterSecureStorage _storage;

  TokenStorage() : _storage = const FlutterSecureStorage();

  // ============================================================
  // SAVE TOKENS
  // ============================================================

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);

    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  // ============================================================
  // SAVE EMAIL
  // ============================================================

  Future<void> saveEmail(String email) async {
    await _storage.write(key: _emailKey, value: email);
  }

  // ============================================================
  // GET ACCESS TOKEN
  // ============================================================

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // ============================================================
  // GET REFRESH TOKEN
  // ============================================================

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // ============================================================
  // GET EMAIL
  // ============================================================

  Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  // ============================================================
  // DELETE EVERYTHING
  // ============================================================

  Future<void> deleteTokens() async {
    await _storage.delete(key: _accessTokenKey);

    await _storage.delete(key: _refreshTokenKey);

    await _storage.delete(key: _emailKey);
  }
}
