import 'dart:convert';
import 'package:appointmentbook/exceptions/unauthorized_exception.dart';
import 'package:appointmentbook/repositories/auth_repository.dart';
import 'package:appointmentbook/services/auth_api_service.dart';
import 'package:appointmentbook/services/token_manager.dart';
import 'package:appointmentbook/storage/token_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserApiService {
  final String baseUrl = 'http://10.0.2.2:5246/api';

  final TokenManager _tokenManager = TokenManager(
    TokenStorage(),
    AuthRepository(apiService: AuthApiService()),
  );

  Future<UserModel> getUserByEmail({
    required String email,
    required String accessToken,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Users/FindUserByEmail/$email'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get user: ${response.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    return UserModel.fromJson(data);
  }

  // ============================================================
  // UPDATE USER
  // ============================================================

  Future<UserModel> updateUser(
    int id,
    UserModel user,
    String accessToken,
  ) async {
    // ============================================================
    // SEND UPDATE REQUEST
    // ============================================================

    var response = await http.put(
      Uri.parse('$baseUrl/Users/UpdateUser/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(user.toJson()),
    );

    // ============================================================
    // ACCESS TOKEN EXPIRED
    // ============================================================

    if (response.statusCode == 401) {
      debugPrint('USER: Access token expired. Trying refresh...');

      final newAccessToken = await _tokenManager.refreshAccessToken();

      if (newAccessToken == null || newAccessToken.isEmpty) {
        debugPrint('USER: Refresh token failed.');

        throw const UnauthorizedException();
      }

      // ============================================================
      // RETRY REQUEST WITH NEW ACCESS TOKEN
      // ============================================================

      response = await http.put(
        Uri.parse('$baseUrl/Users/UpdateUser/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $newAccessToken',
        },
        body: jsonEncode(user.toJson()),
      );

      debugPrint('USER: Retry status: ${response.statusCode}');
    }

    // ============================================================
    // SUCCESS
    // ============================================================

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return UserModel.fromJson(data);
    }

    // ============================================================
    // STILL UNAUTHORIZED
    // ============================================================

    if (response.statusCode == 401) {
      throw const UnauthorizedException();
    }

    // ============================================================
    // OTHER ERRORS
    // ============================================================

    if (response.statusCode == 403) {
      throw Exception('You are not authorized to update this user.');
    }

    if (response.statusCode == 404) {
      throw Exception('User not found.');
    }

    if (response.statusCode == 400) {
      final data = jsonDecode(response.body);

      throw Exception(
        data is Map<String, dynamic>
            ? data['message'] ?? 'Invalid user data.'
            : 'Invalid user data.',
      );
    }

    if (response.statusCode == 409) {
      final data = jsonDecode(response.body);

      throw Exception(
        data is Map<String, dynamic>
            ? data['message'] ?? 'User update conflict.'
            : 'User update conflict.',
      );
    }

    throw Exception('Failed to update user: ${response.statusCode}');
  }
}
