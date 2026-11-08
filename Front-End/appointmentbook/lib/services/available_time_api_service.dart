import 'dart:convert';

import 'package:appointmentbook/exceptions/unauthorized_exception.dart';
import 'package:appointmentbook/models/available_time_model.dart';
import 'package:appointmentbook/repositories/auth_repository.dart';
import 'package:appointmentbook/services/auth_api_service.dart';
import 'package:appointmentbook/services/token_manager.dart';
import 'package:appointmentbook/storage/token_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AvailableTimeApiService {
  final String baseUrl = 'http://10.0.2.2:5246/api';

  final TokenManager _tokenManager = TokenManager(
    TokenStorage(),
    AuthRepository(apiService: AuthApiService()),
  );

  // ============================================================
  // GET ALL AVAILABLE TIMES
  // ============================================================

  Future<List<AvailableTimeModel>> getAllAvailableTimes(
    int businessId,
    String accessToken,
  ) async {
    var response = await http.get(
      Uri.parse('$baseUrl/AvailableTime/AllAvailableTimes/$businessId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    // ============================================================
    // ACCESS TOKEN EXPIRED
    // ============================================================

    if (response.statusCode == 401) {
      debugPrint('AVAILABLE TIME: Access token expired. Trying refresh...');

      final newAccessToken = await _tokenManager.refreshAccessToken();

      if (newAccessToken == null || newAccessToken.isEmpty) {
        debugPrint('AVAILABLE TIME: Refresh token failed.');

        throw const UnauthorizedException();
      }

      debugPrint('AVAILABLE TIME: Refresh succeeded.');

      debugPrint(
        'AVAILABLE TIME: New access token length: '
        '${newAccessToken.length}',
      );

      // ============================================================
      // RETRY REQUEST WITH NEW ACCESS TOKEN
      // ============================================================

      response = await http.get(
        Uri.parse('$baseUrl/AvailableTime/AllAvailableTimes/$businessId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $newAccessToken',
        },
      );

      debugPrint(
        'AVAILABLE TIME: Retry status: '
        '${response.statusCode}',
      );
    }

    // ============================================================
    // SUCCESS
    // ============================================================

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((json) => AvailableTimeModel.fromJson(json)).toList();
    }

    // ============================================================
    // NOT FOUND
    // ============================================================

    if (response.statusCode == 404) {
      throw Exception('No available times found.');
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

    throw Exception(
      'Failed to load available times: '
      '${response.statusCode}',
    );
  }
}
