class AddFavoriteBusinessModel {
  final int id;
  final int userId;
  final int businessId;
  final String message;

  const AddFavoriteBusinessModel({
    required this.id,
    required this.userId,
    required this.businessId,
    required this.message,
  });

  factory AddFavoriteBusinessModel.fromJson(Map<String, dynamic> json) {
    return AddFavoriteBusinessModel(
      id: json['id'],
      userId: json['user_id'],
      businessId: json['business_id'],
      message: json['message'] ?? '',
    );
  }
}
