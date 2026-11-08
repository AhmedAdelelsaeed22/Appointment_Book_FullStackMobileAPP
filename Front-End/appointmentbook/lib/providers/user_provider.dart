import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../services/user_api_service.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(UserApiService());
});

class UserNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    return null;
  }

  Future<void> loadUser({
    required String email,
    required String accessToken,
  }) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(userRepositoryProvider);

      final user = await repository.getUserByEmail(
        email: email,
        accessToken: accessToken,
      );

      state = AsyncData(user);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  void clearUser() {
    state = const AsyncData(null);
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, UserModel?>(
  UserNotifier.new,
);
