class FavoriteBusinessWithDetailsModel {
  final int id;
  final int businessId;
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
  final DateTime createdAt;

  const FavoriteBusinessWithDetailsModel({
    required this.id,
    required this.businessId,
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
    required this.createdAt,
  });

  factory FavoriteBusinessWithDetailsModel.fromJson(Map<String, dynamic> json) {
    return FavoriteBusinessWithDetailsModel(
      id: json['id'],
      businessId: json['business_id'],
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
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
