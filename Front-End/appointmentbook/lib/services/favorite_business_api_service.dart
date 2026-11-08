import 'dart:convert';

import 'package:appointmentbook/exceptions/unauthorized_exception.dart';
import 'package:appointmentbook/models/add_favorite_business_model.dart';
import 'package:appointmentbook/models/favorite_business_with_details_model.dart';
import 'package:appointmentbook/repositories/auth_repository.dart';
import 'package:appointmentbook/services/auth_api_service.dart';
import 'package:appointmentbook/services/token_manager.dart';
import 'package:appointmentbook/storage/token_storage.dart';
import 'package:http/http.dart' as http;

class FavoriteBusinessApiService {
  final String baseUrl = 'http://10.0.2.2:5246/api';

  final TokenManager _tokenManager = TokenManager(
    TokenStorage(),
    AuthRepository(apiService: AuthApiService()),
  );

  // ============================================================
  // GET ALL FAVORITE BUSINESSES
  // ============================================================

  Future<List<FavoriteBusinessWithDetailsModel>> getAllFavoriteBusinesses(
    String accessToken,
  ) async {
    var response = await http.get(
      Uri.parse('$baseUrl/FavoriteBusiness/AllFavorites'),
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
        Uri.parse('$baseUrl/FavoriteBusiness/AllFavorites'),
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

      return data
          .map((json) => FavoriteBusinessWithDetailsModel.fromJson(json))
          .toList();
    }

    // ============================================================
    // UNAUTHORIZED AFTER RETRY
    // ============================================================

    if (response.statusCode == 401) {
      throw const UnauthorizedException();
    }

    throw Exception(
      'Failed to load favorite businesses: ${response.statusCode}',
    );
  }

  // ============================================================
  // ADD FAVORITE BUSINESS
  // ============================================================

  Future<AddFavoriteBusinessModel> addFavoriteBusiness(
    int businessId,
    String accessToken,
  ) async {
    var response = await http.post(
      Uri.parse('$baseUrl/FavoriteBusiness/AddFavorite/$businessId'),
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
      response = await http.post(
        Uri.parse('$baseUrl/FavoriteBusiness/AddFavorite/$businessId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $newAccessToken',
        },
      );
    }

    // ============================================================
    // SUCCESS
    // ============================================================

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return AddFavoriteBusinessModel.fromJson(data);
    }

    // ============================================================
    // UNAUTHORIZED AFTER RETRY
    // ============================================================

    if (response.statusCode == 401) {
      throw const UnauthorizedException();
    }

    // ============================================================
    // OTHER ERRORS
    // ============================================================

    if (response.statusCode == 400) {
      final data = jsonDecode(response.body);

      throw Exception(data['message'] ?? 'Invalid business id.');
    }

    if (response.statusCode == 404) {
      final data = jsonDecode(response.body);

      throw Exception(data['message'] ?? 'Business not found.');
    }

    if (response.statusCode == 409) {
      final data = jsonDecode(response.body);

      throw Exception(data['message'] ?? 'Business is already in favorites.');
    }

    throw Exception('Failed to add favorite business: ${response.statusCode}');
  }

  // ============================================================
  // REMOVE FAVORITE BUSINESS
  // ============================================================

  Future<void> removeFavoriteBusiness(
    int businessId,
    String accessToken,
  ) async {
    var response = await http.delete(
      Uri.parse('$baseUrl/FavoriteBusiness/RemoveFavorite/$businessId'),
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
      response = await http.delete(
        Uri.parse('$baseUrl/FavoriteBusiness/RemoveFavorite/$businessId'),
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
      return;
    }

    // ============================================================
    // UNAUTHORIZED AFTER RETRY
    // ============================================================

    if (response.statusCode == 401) {
      throw const UnauthorizedException();
    }

    // ============================================================
    // OTHER ERRORS
    // ============================================================

    if (response.statusCode == 400) {
      final data = jsonDecode(response.body);

      throw Exception(data['message'] ?? 'Invalid business id.');
    }

    if (response.statusCode == 404) {
      final data = jsonDecode(response.body);

      throw Exception(data['message'] ?? 'Favorite business was not found.');
    }

    throw Exception(
      'Failed to remove favorite business: ${response.statusCode}',
    );
  }
}
