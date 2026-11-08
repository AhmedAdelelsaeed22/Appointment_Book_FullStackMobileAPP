import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserApiService {
  final String baseUrl = 'http://10.0.2.2:5246/api';

  Future<UserModel> getUserByEmail({
    required String email,
    required String accessToken,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Users/FindUserByEmail/$email'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get user: ${response.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    return UserModel.fromJson(data);
  }
}
