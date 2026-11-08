class ChnagePasswordRequest {
  final String email;
  final String newPassword;

  ChnagePasswordRequest({required this.email, required this.newPassword});

  Map<String, dynamic> toJson() {
    return {'email': email, 'newPassword': newPassword};
  }
}
