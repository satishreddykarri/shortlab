import '../../../core/network/api_client.dart';

class ShortUrl {
  const ShortUrl({
    required this.id,
    required this.originalUrl,
    required this.shortCode,
    required this.algorithm,
    required this.createdAt,
    this.expiresAt,
  });

  final int id;
  final String originalUrl;
  final String shortCode;
  final String algorithm;
  final DateTime createdAt;
  final DateTime? expiresAt;

  factory ShortUrl.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final originalUrl = json['original_url'];
    final shortCode = json['short_code'];
    final algorithm = json['algorithm'];
    final createdAtValue = json['created_at'];
    final expiresAtValue = json['expires_at'];

    if (id is! num ||
        originalUrl is! String ||
        shortCode is! String ||
        algorithm is! String ||
        createdAtValue is! String) {
      throw const ApiException('The server returned an invalid URL record.');
    }

    final createdAt = DateTime.tryParse(createdAtValue);
    final expiresAt = switch (expiresAtValue) {
      null => null,
      String value => DateTime.tryParse(value),
      _ => null,
    };
    if (createdAt == null || (expiresAtValue != null && expiresAt == null)) {
      throw const ApiException('The server returned an invalid URL record.');
    }

    return ShortUrl(
      id: id.toInt(),
      originalUrl: originalUrl,
      shortCode: shortCode,
      algorithm: algorithm,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }
}
