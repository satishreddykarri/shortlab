import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl;

  final http.Client _client;
  final String? _baseUrl;

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, Object?> body, {
    required int expectedStatus,
  }) async {
    final Uri uri;
    try {
      final baseUri = Uri.parse(_baseUrl ?? ApiConfig.baseUrl);
      if (!baseUri.hasScheme || !baseUri.hasAuthority) {
        throw const FormatException();
      }
      uri = baseUri.resolve(path);
    } on StateError catch (error) {
      throw ApiException(error.message);
    } on FormatException {
      throw const ApiException('The API base URL is invalid.');
    }

    final http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const ApiException('The request timed out. Please try again.');
    } on http.ClientException {
      throw const ApiException(
        'Could not reach the server. Check your connection and try again.',
      );
    }

    final Map<String, dynamic> decoded;
    try {
      final value = jsonDecode(response.body);
      if (value is! Map<String, dynamic>) {
        throw const FormatException();
      }
      decoded = value;
    } on FormatException {
      if (response.statusCode == expectedStatus && response.body.isEmpty) {
        return {};
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          'The server returned an unexpected response '
          '(${response.statusCode}).',
        );
      }
      throw const ApiException('The server returned an invalid response.');
    }

    if (response.statusCode != expectedStatus) {
      throw ApiException(
        _errorMessage(decoded) ??
            'The request failed (${response.statusCode}). Please try again.',
      );
    }

    return decoded;
  }

  String? _errorMessage(Map<String, dynamic> response) {
    final error = response['error'];
    if (error is String && error.trim().isNotEmpty) {
      return error;
    }
    if (error is Map<String, dynamic>) {
      final message = error['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    final message = response['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
    return null;
  }

  void close() => _client.close();
}
