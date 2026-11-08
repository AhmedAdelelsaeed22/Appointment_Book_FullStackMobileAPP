class AppointmentModel {
  final int id;
  final int businessId;
  final int customerId;
  final int serviceId;
  final DateTime startDatetime;
  final DateTime endDatetime;
  final String? customerNotes;
  final int staffId;

  const AppointmentModel({
    required this.id,
    required this.businessId,
    required this.customerId,
    required this.serviceId,
    required this.startDatetime,
    required this.endDatetime,
    this.customerNotes,
    required this.staffId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'customer_id': customerId,
      'service_id': serviceId,
      'start_datetime': startDatetime.toUtc().toIso8601String(),
      'end_datetime': endDatetime.toUtc().toIso8601String(),
      'customer_notes': customerNotes,
      'staff_id': staffId,
    };
  }
}
