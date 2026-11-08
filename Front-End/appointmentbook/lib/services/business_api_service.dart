import 'dart:convert';
import 'package:appointmentbook/exceptions/unauthorized_exception.dart';
import 'package:appointmentbook/models/business_with_category_model.dart';
import 'package:appointmentbook/repositories/auth_repository.dart';
import 'package:appointmentbook/services/auth_api_service.dart';
import 'package:appointmentbook/services/token_manager.dart';
import 'package:appointmentbook/storage/token_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BusinessApiService {
  final String baseUrl = 'http://10.0.2.2:5246/api';

  final TokenManager _tokenManager = TokenManager(
    TokenStorage(),
    AuthRepository(apiService: AuthApiService()),
  );

  // ============================================================
  // GET ALL BUSINESSES
  // ============================================================

  Future<List<BusinessWithCategoryModel>> getAllBusinesses(
    String accessToken,
  ) async {
    var response = await http.get(
      Uri.parse('$baseUrl/Business/AllBusinesses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    // ============================================================
    // ACCESS TOKEN EXPIRED
    // ============================================================

    if (response.statusCode == 401) {
      debugPrint('BUSINESS: Access token expired. Trying refresh...');

      final newAccessToken = await _tokenManager.refreshAccessToken();

      if (newAccessToken == null || newAccessToken.isEmpty) {
        debugPrint('BUSINESS: Refresh token failed.');

        throw const UnauthorizedException();
      }

      // debugPrint('BUSINESS: Refresh succeeded.');
      // debugPrint('BUSINESS: New access token length: ${newAccessToken.length}');

      response = await http.get(
        Uri.parse('$baseUrl/Business/AllBusinesses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $newAccessToken',
        },
      );

      debugPrint('BUSINESS: Retry status: ${response.statusCode}');
    }

    // ============================================================
    // SUCCESS
    // ============================================================

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((json) => BusinessWithCategoryModel.fromJson(json))
          .toList();
    }

    // ============================================================
    // STILL UNAUTHORIZED
    // ============================================================

    if (response.statusCode == 401) {
      throw const UnauthorizedException();
    }

    throw Exception('Failed to load businesses: ${response.statusCode}');
  }
}
