class SignupRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String password;
  final String? profileImageUrl;

  SignupRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    required this.profileImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'password': password,
      'profile_image_url': profileImageUrl,
    };
  }
}
