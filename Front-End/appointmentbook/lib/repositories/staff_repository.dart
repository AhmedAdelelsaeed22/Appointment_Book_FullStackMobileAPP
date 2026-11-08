import 'package:appointmentbook/models/staff_model.dart';

import '../services/staff_api_service.dart';

class StaffRepository {
  final StaffApiService _apiService;

  StaffRepository(this._apiService);

  Future<List<StaffModel>> getAllStaff(int businessId, String accessToken) {
    return _apiService.getAllStaff(businessId, accessToken);
  }
}
