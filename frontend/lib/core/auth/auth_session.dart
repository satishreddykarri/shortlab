import 'package:flutter/foundation.dart';

class AuthSession extends ChangeNotifier {
  String? _token;

  bool get isAuthenticated => _token != null;
  String? get token => _token;

  void login(String token) {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) {
      throw ArgumentError.value(token, 'token', 'JWT must not be empty.');
    }
    _token = normalizedToken;
    notifyListeners();
  }

  void logout() {
    if (_token == null) return;
    _token = null;
    notifyListeners();
  }
}
