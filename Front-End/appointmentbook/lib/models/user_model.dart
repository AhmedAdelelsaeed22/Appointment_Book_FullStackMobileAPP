class UserModel {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String password;
  final String? image;
  final bool isActive;
  final DateTime createAt;
  final String userRole;

  const UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.password,
    this.image,
    required this.isActive,
    required this.createAt,
    required this.userRole,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      password: json['password_hash'] ?? '',
      image: json['profile_image_url'],
      isActive: json['is_active'],
      createAt: DateTime.parse(json['created_at']),
      userRole: json['user_role'] ?? '',
    );
  }
}
