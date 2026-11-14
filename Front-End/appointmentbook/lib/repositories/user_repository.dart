import 'package:appointmentbook/models/logout_request.dart';
import 'package:appointmentbook/services/auth_api_service.dart';

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

  Future<UserModel> updateUser(int id, UserModel user, String accessToken) {
    return _userApiService.updateUser(id, user, accessToken);
  }
}
