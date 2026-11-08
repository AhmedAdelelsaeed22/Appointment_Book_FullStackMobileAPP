class AppointmentListModel {
  final int id;
  final int businessId;
  final String businessName;
  final int customerId;
  final String customerName;
  final int serviceId;
  final String serviceName;
  final int statusId;
  final String statusName;
  final DateTime startDatetime;
  final DateTime endDatetime;
  final String? customerNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? cancelledAt;
  final DateTime? completedAt;
  final int staffId;
  final String? staffName;

  const AppointmentListModel({
    required this.id,
    required this.businessId,
    required this.businessName,
    required this.customerId,
    required this.customerName,
    required this.serviceId,
    required this.serviceName,
    required this.statusId,
    required this.statusName,
    required this.startDatetime,
    required this.endDatetime,
    this.customerNotes,
    required this.createdAt,
    required this.updatedAt,
    this.cancelledAt,
    this.completedAt,
    required this.staffId,
    this.staffName,
  });

  factory AppointmentListModel.fromJson(Map<String, dynamic> json) {
    return AppointmentListModel(
      id: (json['id'] as num).toInt(),
      businessId: (json['business_id'] as num).toInt(),
      businessName: json['business_name'] ?? '',
      customerId: (json['customer_id'] as num).toInt(),
      customerName: json['customer_name'] ?? '',
      serviceId: (json['service_id'] as num).toInt(),
      serviceName: json['service_name'] ?? '',
      statusId: (json['status_id'] as num).toInt(),
      statusName: json['status_name'] ?? '',
      startDatetime: DateTime.parse(json['start_datetime']),
      endDatetime: DateTime.parse(json['end_datetime']),
      customerNotes: json['customer_notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      cancelledAt: json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at']),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at']),
      staffId: (json['staff_id'] as num).toInt(),
      staffName: json['staff_name'],
    );
  }
}
