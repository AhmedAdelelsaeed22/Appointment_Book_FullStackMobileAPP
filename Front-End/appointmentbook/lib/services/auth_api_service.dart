import 'dart:convert';
import 'package:appointmentbook/models/chnage_password_request.dart';
import 'package:appointmentbook/models/google_login_request.dart';
import 'package:appointmentbook/models/login_response.dart';
import 'package:appointmentbook/models/refresh_token_request.dart';
import 'package:appointmentbook/models/send_otp_request.dart';
import 'package:appointmentbook/models/otp_verification_request.dart';
import 'package:appointmentbook/models/signup_request.dart';
import 'package:http/http.dart' as http;
import '../models/login_request.dart';

class AuthApiService {
  final String baseUrl = 'http://10.0.2.2:5246/api';

  Future<LoginResponse?> login(LoginRequest request) async {
    final url = Uri.parse('$baseUrl/Auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return LoginResponse.fromJson(data);
    }

    throw Exception('Login failed: ${response.statusCode}');
  }

  Future<LoginResponse?> refreshToken(RefreshTokenRequest request) async {
    final url = Uri.parse('$baseUrl/Auth/refresh');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return LoginResponse.fromJson(data);
    }

    throw Exception('refresh token failed: ${response.statusCode}');
  }

  Future<bool> sendOTP(SendOtpRequest request) async {
    final url = Uri.parse('$baseUrl/Auth/SendOTP');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    }

    throw Exception(
      'Send OTP failed: ${response.statusCode}\n'
      'Response: ${response.body}',
    );
  }

  Future<bool> oTPVerification(OtpVerificationRequest request) async {
    final url = Uri.parse('$baseUrl/Auth/OTPVerification');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    }

    throw Exception('Otp Verification Is Fail: ${response.statusCode}');
  }

  Future<bool> changePassword(ChnagePasswordRequest request) async {
    final url = Uri.parse('$baseUrl/Auth/ChangePassword');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    }

    throw Exception('Password Change Is Fail: ${response.statusCode}');
  }

  Future<bool> signUp(SignupRequest request) async {
    final url = Uri.parse('$baseUrl/Auth/SignUp');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    }

    throw Exception('sign up Is Fail: ${response.statusCode}');
  }

  Future<LoginResponse> loginWithGoogle(GoogleLoginRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/LoginUsingGoogle'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return LoginResponse.fromJson(data);
    }
    throw Exception('Google login failed: ${response.statusCode}');
  }
}
