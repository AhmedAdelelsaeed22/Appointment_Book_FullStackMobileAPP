class BusinessModel {
  final int id;
  final int ownerId;
  final String name;
  final String? description;
  final String email;
  final String phone;
  final String? logoUrl;
  final String timezone;
  final bool isOpen;
  final int serviceCategoryId;
  final double rating;
  final String location;

  const BusinessModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    required this.email,
    required this.phone,
    this.logoUrl,
    required this.timezone,
    required this.isOpen,
    required this.serviceCategoryId,
    required this.rating,
    required this.location,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as int,
      ownerId: json['owner_id'] as int,
      name: json['name'] ?? '',
      description: json['description'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      logoUrl: json['logo_url'],
      timezone: json['timezone'] ?? '',
      isOpen: json['is_open'] ?? false,
      serviceCategoryId: json['service_category_id'] as int,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'email': email,
      'phone': phone,
      'logo_url': logoUrl,
      'timezone': timezone,
      'is_open': isOpen,
      'service_category_id': serviceCategoryId,
      'rating': rating,
      'location': location,
    };
  }
}
