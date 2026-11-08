class OtpVerificationRequest {
  final String email;
  final String otp;

  OtpVerificationRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp': otp};
  }
}
