import 'dart:convert';

import 'package:appointmentbook/exceptions/unauthorized_exception.dart';
import 'package:appointmentbook/models/appointment_details_model.dart';
import 'package:appointmentbook/models/appointment_list_model.dart';
import 'package:appointmentbook/models/appointment_model.dart';
import 'package:appointmentbook/repositories/auth_repository.dart';
import 'package:appointmentbook/services/auth_api_service.dart';
import 'package:appointmentbook/services/token_manager.dart';
import 'package:appointmentbook/storage/token_storage.dart';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AppointmentApiService {
  final String baseUrl = 'http://10.0.2.2:5246/api';

  final TokenManager _tokenManager = TokenManager(
    TokenStorage(),
    AuthRepository(apiService: AuthApiService()),
  );

  // ============================================================
  // COMMON: SEND REQUEST WITH ACCESS TOKEN
  // ============================================================

  Future<http.Response> _sendWithAuth(
    String accessToken,
    Future<http.Response> Function(String token) request,
  ) async {
    // First request using the current access token.
    var response = await request(accessToken);

    // If the access token expired, try to refresh it.
    if (response.statusCode == 401) {
      debugPrint('APPOINTMENT: Access token expired. Trying refresh...');

      final newAccessToken = await _tokenManager.refreshAccessToken();

      if (newAccessToken == null || newAccessToken.isEmpty) {
        debugPrint('APPOINTMENT: Refresh token failed.');

        throw const UnauthorizedException();
      }

      debugPrint('APPOINTMENT: Refresh succeeded.');

      // Retry the original request once using the new token.
      response = await request(newAccessToken);

      debugPrint('APPOINTMENT: Retry status: ${response.statusCode}');
    }

    // If the retry also returns 401, authentication failed.
    if (response.statusCode == 401) {
      throw const UnauthorizedException();
    }

    return response;
  }

  // ============================================================
  // COMMON: CREATE REQUEST HEADERS
  // ============================================================

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // COMMON: HANDLE UNSUCCESSFUL RESPONSES
  // ============================================================

  Exception _requestException(String operation, http.Response response) {
    return Exception(
      '$operation failed: ${response.statusCode}'
      '${response.body.isNotEmpty ? ' - ${response.body}' : ''}',
    );
  }

  // ============================================================
  // 1. GET APPOINTMENT BY ID
  // ============================================================

  Future<AppointmentDetailsModel?> getAppointmentById(
    int appointmentId,
    String accessToken,
  ) async {
    final response = await _sendWithAuth(
      accessToken,
      (token) => http.get(
        Uri.parse('$baseUrl/Appointments/GetAppointmentById/$appointmentId'),
        headers: _headers(token),
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return AppointmentDetailsModel.fromJson(data);
    }

    if (response.statusCode == 404) {
      return null;
    }

    throw _requestException('Get appointment by ID', response);
  }

  // ============================================================
  // 2. GET ALL APPOINTMENTS BY USER ID
  // ============================================================

  Future<List<AppointmentListModel>> getAllAppointmentsByUserId(
    int userId,
    String accessToken,
  ) async {
    final response = await _sendWithAuth(
      accessToken,
      (token) => http.get(
        Uri.parse('$baseUrl/Appointments/GetAllAppointmentsByUserId/$userId'),
        headers: _headers(token),
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map(
            (json) =>
                AppointmentListModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    }

    throw _requestException('Get appointments by user ID', response);
  }

  // ============================================================
  // 3. CREATE APPOINTMENT
  // ============================================================

  Future<AppointmentDetailsModel> createAppointment(
    AppointmentModel appointment,
    String accessToken,
  ) async {
    final response = await _sendWithAuth(
      accessToken,
      (token) => http.post(
        Uri.parse('$baseUrl/Appointments/CreateAppointment'),
        headers: _headers(token),
        body: jsonEncode(appointment.toJson()),
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return AppointmentDetailsModel.fromJson(data);
    }

    throw _requestException('Create appointment', response);
  }

  // ============================================================
  // 4. UPDATE APPOINTMENT
  // ============================================================

  Future<AppointmentDetailsModel> updateAppointment(
    int appointmentId,
    AppointmentModel appointment,
    String accessToken, {
    String? reason,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/Appointments/UpdateAppointment/$appointmentId',
    ).replace(queryParameters: reason == null ? null : {'reason': reason});

    final response = await _sendWithAuth(
      accessToken,
      (token) => http.put(
        uri,
        headers: _headers(token),
        body: jsonEncode(appointment.toJson()),
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return AppointmentDetailsModel.fromJson(data);
    }

    throw _requestException('Update appointment', response);
  }

  // ============================================================
  // 6. CANCEL APPOINTMENT
  // ============================================================

  Future<AppointmentDetailsModel> cancelAppointment(
    int appointmentId,
    String reason,
    String accessToken,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/Appointments/CancelAppointment/$appointmentId',
    ).replace(queryParameters: {'reason': reason});

    final response = await _sendWithAuth(
      accessToken,
      (token) => http.post(uri, headers: _headers(token)),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return AppointmentDetailsModel.fromJson(data);
    }

    throw _requestException('Cancel appointment', response);
  }
}
