import '../../../core/network/api_client.dart';
import 'short_url.dart';
import 'url_analytics.dart';

class UrlApi {
  UrlApi(this._client);

  final ApiClient _client;

  Future<ShortUrl> create({
    required String originalUrl,
    required String algorithm,
    String? customAlias,
    DateTime? expiresAt,
  }) async {
    final body = <String, Object?>{
      'original_url': originalUrl,
      'algorithm': algorithm,
      if (algorithm == 'custom' && customAlias != null)
        'custom_alias': customAlias,
      if (expiresAt != null) 'expires_at': expiresAt.toUtc().toIso8601String(),
    };
    final response = await _client.postJson(
      '/api/urls',
      body,
      expectedStatus: 201,
      authenticated: true,
    );
    final url = response['url'];
    if (url is! Map<String, dynamic>) {
      throw const ApiException('The server returned an invalid URL record.');
    }
    return ShortUrl.fromJson(url);
  }

  Future<List<ShortUrl>> list() async {
    final response = await _client.getJson(
      '/api/urls',
      expectedStatus: 200,
      authenticated: true,
    );
    final urls = response['urls'];
    if (urls is! List) {
      throw const ApiException('The server returned an invalid URL list.');
    }
    return urls
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const ApiException(
              'The server returned an invalid URL record.',
            );
          }
          return ShortUrl.fromJson(item);
        })
        .toList(growable: false);
  }

  Future<void> delete(int id) async {
    await _client.deleteJson(
      '/api/urls/$id',
      expectedStatus: 200,
      authenticated: true,
    );
  }

  Future<UrlAnalytics> analytics(int id) async {
    final response = await _client.getJson(
      '/api/urls/$id/analytics',
      expectedStatus: 200,
      authenticated: true,
    );
    final analytics = response['analytics'];
    if (analytics is! Map<String, dynamic>) {
      throw const ApiException('The server returned invalid URL analytics.');
    }
    return UrlAnalytics.fromJson(analytics);
  }
}
