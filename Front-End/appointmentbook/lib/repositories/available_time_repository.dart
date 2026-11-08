import 'package:appointmentbook/models/available_time_model.dart';

import '../services/available_time_api_service.dart';

class AvailableTimeRepository {
  final AvailableTimeApiService _apiService;

  AvailableTimeRepository(this._apiService);

  Future<List<AvailableTimeModel>> getAllAvailableTimes(
    int businessId,
    String accessToken,
  ) {
    return _apiService.getAllAvailableTimes(businessId, accessToken);
  }
}
