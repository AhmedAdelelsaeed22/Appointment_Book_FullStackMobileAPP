import '../models/user_model.dart';
import '../services/user_api_service.dart';

class UserRepository {
  final UserApiService _userApiService;

  UserRepository(this._userApiService);

  Future<UserModel> getUserByEmail({
    required String email,
    required String accessToken,
  }) async {
    return await _userApiService.getUserByEmail(
      email: email,
      accessToken: accessToken,
    );
  }
}
