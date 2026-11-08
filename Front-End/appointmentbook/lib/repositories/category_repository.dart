import 'package:appointmentbook/models/category_model.dart';

import '../services/category_api_service.dart';

class CategoryRepository {
  final CategoryApiService _apiService;

  CategoryRepository(this._apiService);

  Future<List<CategoryModel>> getAllCategories(String accessToken) {
    return _apiService.getAllCategories(accessToken);
  }
}
