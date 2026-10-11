import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig._();

  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    if (kReleaseMode) {
      throw StateError('Set API_BASE_URL when building a release.');
    }

    return 'http://localhost:8080';
  }
}
