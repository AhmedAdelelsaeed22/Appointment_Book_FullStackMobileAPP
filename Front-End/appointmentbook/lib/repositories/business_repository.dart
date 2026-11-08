import 'package:appointmentbook/models/business_with_category_model.dart';

import '../services/business_api_service.dart';

class BusinessRepository {
  final BusinessApiService _apiService;

  BusinessRepository(this._apiService);

  Future<List<BusinessWithCategoryModel>> getAllBusinesses(String accessToken) {
    return _apiService.getAllBusinesses(accessToken);
  }
}
