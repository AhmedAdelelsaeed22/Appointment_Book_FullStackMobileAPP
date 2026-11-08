import '../models/favorite_business_with_details_model.dart';
import '../repositories/favorite_business_repository.dart';
import '../services/favorite_business_api_service.dart';
import '../storage/token_storage.dart';

class FavoritesManager {
  late final TokenStorage _tokenStorage;
  late final FavoriteBusinessRepository _favoriteBusinessRepository;

  FavoritesManager() {
    _tokenStorage = TokenStorage();
    _favoriteBusinessRepository = FavoriteBusinessRepository(
      FavoriteBusinessApiService(),
    );
  }

  // ==============================================================
  // GET ALL FAVORITES
  // ==============================================================

  Future<List<FavoriteBusinessWithDetailsModel>> getAllFavorites() async {
    final accessToken = await _tokenStorage.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token not found.');
    }

    return await _favoriteBusinessRepository.getAllFavoriteBusinesses(
      accessToken,
    );
  }

  // ==============================================================
  // ADD FAVORITE
  // ==============================================================

  Future<bool> addFavorite(int businessId) async {
    final accessToken = await _tokenStorage.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token not found.');
    }

    await _favoriteBusinessRepository.addFavoriteBusiness(
      businessId,
      accessToken,
    );

    return true;
  }

  // ==============================================================
  // REMOVE FAVORITE
  // ==============================================================

  Future<bool> removeFavorite(int businessId) async {
    final accessToken = await _tokenStorage.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token not found.');
    }

    await _favoriteBusinessRepository.removeFavoriteBusiness(
      businessId,
      accessToken,
    );

    return true;
  }
}

final favoritesManager = FavoritesManager();
