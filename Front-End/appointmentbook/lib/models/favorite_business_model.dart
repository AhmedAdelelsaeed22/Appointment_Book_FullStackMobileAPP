class FavoriteBusinessModel {
  final int id;
  final int userId;
  final int businessId;
  final DateTime createdAt;

  const FavoriteBusinessModel({
    required this.id,
    required this.userId,
    required this.businessId,
    required this.createdAt,
  });

  factory FavoriteBusinessModel.fromJson(Map<String, dynamic> json) {
    return FavoriteBusinessModel(
      id: json['id'],
      userId: json['user_id'],
      businessId: json['business_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
