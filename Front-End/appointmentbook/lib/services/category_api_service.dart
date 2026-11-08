import 'dart:convert';

import 'package:appointmentbook/exceptions/unauthorized_exception.dart';
import 'package:appointmentbook/models/category_model.dart';
import 'package:appointmentbook/repositories/auth_repository.dart';
import 'package:appointmentbook/services/auth_api_service.dart';
import 'package:appointmentbook/services/token_manager.dart';
import 'package:appointmentbook/storage/token_storage.dart';
import 'package:http/http.dart' as http;

class CategoryApiService {
  final String baseUrl = 'http://10.0.2.2:5246/api';

  final TokenManager _tokenManager = TokenManager(
    TokenStorage(),
    AuthRepository(apiService: AuthApiService()),
  );

  // ============================================================
  // GET ALL CATEGORIES
  // ============================================================

  Future<List<CategoryModel>> getAllCategories(String accessToken) async {
    var response = await http.get(
      Uri.parse('$baseUrl/Categories/AllCategories'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    // ============================================================
    // REFRESH TOKEN
    // ============================================================

    if (response.statusCode == 401) {
      final newAccessToken = await _tokenManager.refreshAccessToken();

      if (newAccessToken == null || newAccessToken.isEmpty) {
        throw const UnauthorizedException();
      }

      // Retry request with new access token
      response = await http.get(
        Uri.parse('$baseUrl/Categories/AllCategories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $newAccessToken',
        },
      );
    }

    // ============================================================
    // SUCCESS
    // ============================================================

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((json) => CategoryModel.fromJson(json)).toList();
    }

    // ============================================================
    // UNAUTHORIZED AFTER RETRY
    // ============================================================

    if (response.statusCode == 401) {
      throw const UnauthorizedException();
    }

    throw Exception('Failed to load categories: ${response.statusCode}');
  }
}
