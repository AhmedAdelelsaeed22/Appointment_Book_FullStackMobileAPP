import 'package:appointmentbook/models/appointment_details_model.dart';
import 'package:appointmentbook/models/appointment_list_model.dart';
import 'package:appointmentbook/models/appointment_model.dart';
import 'package:appointmentbook/services/appointment_api_service.dart';

class AppointmentRepository {
  final AppointmentApiService _apiService;

  AppointmentRepository(this._apiService);

  // GET APPOINTMENT BY ID

  Future<AppointmentDetailsModel?> getAppointmentById(
    int appointmentId,
    String accessToken,
  ) {
    return _apiService.getAppointmentById(appointmentId, accessToken);
  }

  // GET ALL APPOINTMENTS BY USER ID

  Future<List<AppointmentListModel>> getAllAppointmentsByUserId(
    int userId,
    String accessToken,
  ) {
    return _apiService.getAllAppointmentsByUserId(userId, accessToken);
  }

  // CREATE APPOINTMENT

  Future<AppointmentDetailsModel> createAppointment(
    AppointmentModel appointment,
    String accessToken,
  ) {
    return _apiService.createAppointment(appointment, accessToken);
  }

  // UPDATE APPOINTMENT

  Future<AppointmentDetailsModel> updateAppointment(
    int appointmentId,
    AppointmentModel appointment,
    String accessToken, {
    String? reason,
  }) {
    return _apiService.updateAppointment(
      appointmentId,
      appointment,
      accessToken,
      reason: reason,
    );
  }

  // CANCEL APPOINTMENT

  Future<AppointmentDetailsModel> cancelAppointment(
    int appointmentId,
    String reason,
    String accessToken,
  ) {
    return _apiService.cancelAppointment(appointmentId, reason, accessToken);
  }
}
