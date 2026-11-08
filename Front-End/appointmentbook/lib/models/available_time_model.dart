class AvailableTimeModel {
  final int id;
  final int businessId;
  final String availableTime;

  const AvailableTimeModel({
    required this.id,
    required this.businessId,
    required this.availableTime,
  });

  factory AvailableTimeModel.fromJson(Map<String, dynamic> json) {
    return AvailableTimeModel(
      id: json['id'] as int,
      businessId: json['business_id'] as int,
      availableTime: json['available_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'available_time': availableTime,
    };
  }
}
