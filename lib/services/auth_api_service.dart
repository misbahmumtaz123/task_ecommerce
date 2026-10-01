import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

/// Contract for Authentication API operations
abstract class AuthApiService {
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  });

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });
}

/// Concrete implementation of [AuthApiService] using DummyJSON
class AuthApiServiceImpl implements AuthApiService {
  final ApiClient _client;

  AuthApiServiceImpl({ApiClient? client}) : _client = client ?? ApiClient();

  @override
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await _client.post(
      ApiConstants.authLogin,
      body: {
        'username': username.trim(),
        'password': password.trim(),
        'expiresInMins': 60,
      },
    );
    return response as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await _client.post(
      ApiConstants.usersAdd,
      body: {
        'username': username.trim(),
        'email': email.trim(),
        'password': password.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
      },
    );
    return response as Map<String, dynamic>;
  }
}
