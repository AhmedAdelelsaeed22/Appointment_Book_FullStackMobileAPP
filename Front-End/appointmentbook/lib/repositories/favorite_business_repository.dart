import 'package:appointmentbook/models/add_favorite_business_model.dart';
import 'package:appointmentbook/models/favorite_business_with_details_model.dart';

import '../services/favorite_business_api_service.dart';

class FavoriteBusinessRepository {
  final FavoriteBusinessApiService _apiService;

  FavoriteBusinessRepository(this._apiService);

  // ============================================================
  // GET ALL FAVORITES
  // ============================================================

  Future<List<FavoriteBusinessWithDetailsModel>> getAllFavoriteBusinesses(
    String accessToken,
  ) {
    return _apiService.getAllFavoriteBusinesses(accessToken);
  }

  // ============================================================
  // ADD FAVORITE
  // ============================================================

  Future<AddFavoriteBusinessModel> addFavoriteBusiness(
    int businessId,
    String accessToken,
  ) {
    return _apiService.addFavoriteBusiness(businessId, accessToken);
  }

  // ============================================================
  // REMOVE FAVORITE
  // ============================================================

  Future<void> removeFavoriteBusiness(int businessId, String accessToken) {
    return _apiService.removeFavoriteBusiness(businessId, accessToken);
  }
}
