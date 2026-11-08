class RefreshTokenRequest {
  final String refreshToken;
  final String email;

  RefreshTokenRequest({required this.refreshToken, required this.email});

  Map<String, dynamic> toJson() {
    return {'refreshToken': refreshToken, 'email': email};
  }
}
