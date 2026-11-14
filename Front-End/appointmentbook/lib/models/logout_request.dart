class LogoutRequest {
  final String email;
  final String refreshToken;

  const LogoutRequest({required this.email, required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {'email': email, 'refreshToken': refreshToken};
  }
}
