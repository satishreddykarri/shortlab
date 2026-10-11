import '../../../core/network/api_client.dart';
import '../../../core/auth/auth_session.dart';
import '../../urls/data/url_api.dart';

class AuthApi {
  AuthApi({ApiClient? client, AuthSession? session}) {
    _session = session ?? client?.session ?? AuthSession();
    _client = client ?? ApiClient(session: _session);
    _client.session = _session;
  }

  late final ApiClient _client;
  late final AuthSession _session;

  AuthSession get session => _session;
  UrlApi get urls => UrlApi(_client);

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

  Future<void> login({required String email, required String password}) async {
    final response = await _client.postJson('/api/auth/login', {
      'email': email,
      'password': password,
    }, expectedStatus: 200);
    final token = response['token'];
    if (token is! String || token.trim().isEmpty) {
      throw const ApiException(
        'The server did not return a valid login token.',
      );
    }
    _session.login(token);
  }

  void close() => _client.close();
}
