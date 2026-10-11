import '../../../core/network/api_client.dart';

class AuthApi {
  AuthApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    await _client.postJson('/api/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
    }, expectedStatus: 201);
  }

  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    await _client.postJson('/api/auth/verify-email', {
      'email': email,
      'code': code,
    }, expectedStatus: 200);
  }

  void close() => _client.close();
}
