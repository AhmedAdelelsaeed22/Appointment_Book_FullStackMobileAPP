class StaffModel {
  final int id;
  final int businessId;
  final String? jobTitle;
  final bool isAvilable;

  const StaffModel({
    required this.id,
    required this.businessId,
    this.jobTitle,
    required this.isAvilable,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] as int,
      businessId: json['business_id'] as int,
      jobTitle: json['job_title'],
      isAvilable: json['is_avilable'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'job_title': jobTitle,
      'is_avilable': isAvilable,
    };
  }
}
