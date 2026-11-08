import 'package:flutter/foundation.dart';

import '../repositories/auth_repository.dart';
import '../storage/token_storage.dart';

class TokenManager {
  final TokenStorage _tokenStorage;
  final AuthRepository _authRepository;

  TokenManager(this._tokenStorage, this._authRepository);

  Future<String?> refreshAccessToken() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    final email = await _tokenStorage.getEmail();

    if (refreshToken == null || refreshToken.isEmpty) {
      debugPrint('TOKEN MANAGER: Refresh token is missing.');
      return null;
    }

    if (email == null || email.isEmpty) {
      debugPrint('TOKEN MANAGER: Email is missing.');
      return null;
    }

    try {
      debugPrint('TOKEN MANAGER: Trying to refresh access token...');

      final response = await _authRepository.refreshToken(
        refreshToken: refreshToken,
        email: email,
      );

      if (response == null) {
        debugPrint('TOKEN MANAGER: Refresh response is null.');
        return null;
      }

      debugPrint('TOKEN MANAGER: Refresh succeeded.');

      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      debugPrint('TOKEN MANAGER: New tokens saved.');

      return response.accessToken;
    } catch (e) {
      debugPrint('TOKEN MANAGER: Refresh failed: $e');
      return null;
    }
  }
}
