class BusinessWithCategoryModel {
  final int id;
  final int ownerId;
  final String name;
  final String? description;
  final String email;
  final String phone;
  final String? logoUrl;
  final String timezone;
  final bool isOpen;
  final String categoryName;
  final double rating;
  final String location;

  const BusinessWithCategoryModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    required this.email,
    required this.phone,
    this.logoUrl,
    required this.timezone,
    required this.isOpen,
    required this.categoryName,
    required this.rating,
    required this.location,
  });

  factory BusinessWithCategoryModel.fromJson(Map<String, dynamic> json) {
    return BusinessWithCategoryModel(
      id: json['id'] as int,
      ownerId: json['owner_id'] as int,
      name: json['name'] ?? '',
      description: json['description'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      logoUrl: json['logo_url'],
      timezone: json['timezone'] ?? '',
      isOpen: json['is_open'] ?? false,
      categoryName: json['category_name'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] ?? '',
    );
  }
}
