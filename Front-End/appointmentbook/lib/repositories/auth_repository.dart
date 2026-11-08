import 'package:appointmentbook/models/chnage_password_request.dart';
import 'package:appointmentbook/models/google_login_request.dart';
import 'package:appointmentbook/models/login_response.dart';
import 'package:appointmentbook/models/otp_verification_request.dart';
import 'package:appointmentbook/models/refresh_token_request.dart';
import 'package:appointmentbook/models/send_otp_request.dart';
import 'package:appointmentbook/models/signup_request.dart';
import '../models/login_request.dart';
import '../services/auth_api_service.dart';

class AuthRepository {
  final AuthApiService apiService;

  AuthRepository({required this.apiService});

  Future<LoginResponse?> login({
    required String email,
    required String password,
  }) async {
    final request = LoginRequest(email: email, password: password);

    return await apiService.login(request);
  }

  Future<LoginResponse?> refreshToken({
    required String refreshToken,
    required String email,
  }) async {
    final request = RefreshTokenRequest(
      email: email,
      refreshToken: refreshToken,
    );

    return await apiService.refreshToken(request);
  }

  Future<bool> sendOTP({required String email}) async {
    final request = SendOtpRequest(email: email);

    return await apiService.sendOTP(request);
  }

  Future<bool> otpVerification({
    required String email,
    required String otp,
  }) async {
    final request = OtpVerificationRequest(email: email, otp: otp);

    return await apiService.oTPVerification(request);
  }

  Future<bool> changePassword({
    required String email,
    required String newPassword,
  }) async {
    final request = ChnagePasswordRequest(
      email: email,
      newPassword: newPassword,
    );

    return await apiService.changePassword(request);
  }

  Future<bool> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String? phone,
    required String password,
    required String? profileImageUrl,
  }) async {
    final request = SignupRequest(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      phone: phone,
      profileImageUrl: profileImageUrl,
    );

    return await apiService.signUp(request);
  }

  Future<LoginResponse> loginWithGoogle(GoogleLoginRequest request) async {
    return await apiService.loginWithGoogle(request);
  }
}
