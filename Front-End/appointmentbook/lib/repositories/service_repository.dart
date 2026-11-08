import 'package:appointmentbook/models/service_model.dart';

import '../services/service_api_service.dart';

class ServiceRepository {
  final ServiceApiService _apiService;

  ServiceRepository(this._apiService);

  Future<List<ServiceModel>> getAllServices(
    int businessId,
    String accessToken,
  ) {
    return _apiService.getAllServices(businessId, accessToken);
  }
}
