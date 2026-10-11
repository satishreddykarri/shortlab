import '../../../core/network/api_client.dart';

class UrlAnalytics {
  const UrlAnalytics({
    required this.urlId,
    required this.originalUrl,
    required this.shortCode,
    required this.algorithm,
    required this.createdAt,
    required this.totalClicks,
    required this.clicks,
    this.expiresAt,
  });

  final int urlId;
  final String originalUrl;
  final String shortCode;
  final String algorithm;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int totalClicks;
  final List<UrlClick> clicks;

  factory UrlAnalytics.fromJson(Map<String, dynamic> json) {
    final urlId = json['url_id'];
    final originalUrl = json['original_url'];
    final shortCode = json['short_code'];
    final algorithm = json['algorithm'];
    final createdAtValue = json['created_at'];
    final expiresAtValue = json['expires_at'];
    final totalClicks = json['total_clicks'];
    final clicksValue = json['clicks'];

    if (urlId is! num ||
        originalUrl is! String ||
        shortCode is! String ||
        algorithm is! String ||
        createdAtValue is! String ||
        totalClicks is! num ||
        clicksValue is! List) {
      throw const ApiException('The server returned invalid URL analytics.');
    }

    final createdAt = DateTime.tryParse(createdAtValue);
    final expiresAt = switch (expiresAtValue) {
      null => null,
      String value => DateTime.tryParse(value),
      _ => null,
    };
    if (createdAt == null || (expiresAtValue != null && expiresAt == null)) {
      throw const ApiException('The server returned invalid URL analytics.');
    }

    final clicks = clicksValue
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const ApiException(
              'The server returned invalid click details.',
            );
          }
          return UrlClick.fromJson(item);
        })
        .toList(growable: false);

    return UrlAnalytics(
      urlId: urlId.toInt(),
      originalUrl: originalUrl,
      shortCode: shortCode,
      algorithm: algorithm,
      createdAt: createdAt,
      expiresAt: expiresAt,
      totalClicks: totalClicks.toInt(),
      clicks: clicks,
    );
  }
}

class UrlClick {
  const UrlClick({
    required this.id,
    required this.clickedAt,
    required this.ipAddress,
    required this.userAgent,
    required this.referrer,
  });

  final int id;
  final DateTime clickedAt;
  final String ipAddress;
  final String userAgent;
  final String referrer;

  factory UrlClick.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final clickedAtValue = json['clicked_at'];
    final ipAddress = json['ip_address'];
    final userAgent = json['user_agent'];
    final referrer = json['referrer'];

    if (id is! num ||
        clickedAtValue is! String ||
        ipAddress is! String ||
        userAgent is! String ||
        referrer is! String) {
      throw const ApiException('The server returned invalid click details.');
    }
    final clickedAt = DateTime.tryParse(clickedAtValue);
    if (clickedAt == null) {
      throw const ApiException('The server returned invalid click details.');
    }

    return UrlClick(
      id: id.toInt(),
      clickedAt: clickedAt,
      ipAddress: ipAddress,
      userAgent: userAgent,
      referrer: referrer,
    );
  }
}
