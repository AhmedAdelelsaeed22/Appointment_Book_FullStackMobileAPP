class ServiceModel {
  final int id;
  final int businessId;
  final int? categoryId;
  final String name;
  final String? description;
  final int durationMinutes;
  final double price;
  final String currency;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceModel({
    required this.id,
    required this.businessId,
    this.categoryId,
    required this.name,
    this.description,
    required this.durationMinutes,
    required this.price,
    required this.currency,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as int,
      businessId: json['business_id'] as int,
      categoryId: json['category_id'] as int?,
      name: json['name'] ?? '',
      description: json['description'],
      durationMinutes: json['duration_minutes'] as int,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? '',
      isAvailable: json['is_available'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'duration_minutes': durationMinutes,
      'price': price,
      'currency': currency,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
