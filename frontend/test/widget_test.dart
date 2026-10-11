import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shortlab/app.dart';
import 'package:shortlab/core/auth/auth_session.dart';
import 'package:shortlab/core/network/api_client.dart';
import 'package:shortlab/core/widgets/async_state_view.dart';
import 'package:shortlab/features/auth/data/auth_api.dart';

void main() {
  testWidgets('landing page presents ShortLab and account actions', (
    tester,
  ) async {
    final api = _createAuthApi(_RecordingClient([]));
    await tester.pumpWidget(ShortLabApp(authApi: api));

    expect(find.text('ShortLab'), findsOneWidget);
    expect(find.text('Make every link work smarter.'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });

  testWidgets('registration and verification submit backend DTOs', (
    tester,
  ) async {
    final client = _RecordingClient([
      http.Response('{"message":"registration successful","user_id":1}', 201),
      http.Response('{"message":"email verified successfully"}', 200),
    ]);
    final api = _createAuthApi(client);
    addTearDown(api.close);
    await tester.pumpWidget(ShortLabApp(authApi: api));

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('registration-name')),
      'Ari Short',
    );
    await tester.enterText(
      find.byKey(const ValueKey('registration-email')),
      'ari@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('registration-password')),
      'Password@123',
    );
    await tester.enterText(
      find.byKey(const ValueKey('registration-confirm-password')),
      'Password@123',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('register-submit')));
    await tester.tap(find.byKey(const ValueKey('register-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Check your inbox'), findsOneWidget);
    expect(find.text('ari@example.com'), findsOneWidget);
    expect(client.requests, hasLength(1));
    expect(client.requests[0].url.path, '/api/auth/register');
    expect(jsonDecode(client.requests[0].body), {
      'name': 'Ari Short',
      'email': 'ari@example.com',
      'password': 'Password@123',
      'confirm_password': 'Password@123',
    });
    expect(client.requests[0].headers, isNot(contains('Authorization')));

    await tester.enterText(
      find.byKey(const ValueKey('verification-code')),
      '123456',
    );
    await tester.tap(find.byKey(const ValueKey('verify-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Email verified'), findsOneWidget);
    expect(client.requests, hasLength(2));
    expect(client.requests[1].url.path, '/api/auth/verify-email');
    expect(jsonDecode(client.requests[1].body), {
      'email': 'ari@example.com',
      'code': '123456',
    });
    expect(client.requests[1].headers, isNot(contains('Authorization')));

    await tester.tap(find.byKey(const ValueKey('go-to-login')));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('registration validation prevents invalid API requests', (
    tester,
  ) async {
    final client = _RecordingClient([]);
    final api = _createAuthApi(client);
    addTearDown(api.close);
    await tester.pumpWidget(ShortLabApp(authApi: api));

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('register-submit')));
    await tester.tap(find.byKey(const ValueKey('register-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Enter your name.'), findsOneWidget);
    expect(find.text('Enter your email address.'), findsOneWidget);
    expect(find.text('Enter a password.'), findsOneWidget);
    expect(client.requests, isEmpty);
  });

  testWidgets('registration validates email and backend password rules', (
    tester,
  ) async {
    final client = _RecordingClient([]);
    final api = _createAuthApi(client);
    addTearDown(api.close);
    await tester.pumpWidget(ShortLabApp(authApi: api));

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('registration-name')),
      'Ari Short',
    );
    await tester.enterText(
      find.byKey(const ValueKey('registration-email')),
      'not-an-email',
    );
    await tester.enterText(
      find.byKey(const ValueKey('registration-password')),
      'weak',
    );
    await tester.enterText(
      find.byKey(const ValueKey('registration-confirm-password')),
      'different',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('register-submit')));
    await tester.tap(find.byKey(const ValueKey('register-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(
      find.text('Password must be at least 8 characters.'),
      findsOneWidget,
    );
    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(client.requests, isEmpty);
  });

  testWidgets('registration displays backend errors and stays on the form', (
    tester,
  ) async {
    final client = _RecordingClient([
      http.Response('{"error":"email already exists"}', 400),
    ]);
    final api = _createAuthApi(client);
    addTearDown(api.close);
    await tester.pumpWidget(ShortLabApp(authApi: api));

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('registration-name')),
      'Ari Short',
    );
    await tester.enterText(
      find.byKey(const ValueKey('registration-email')),
      'ari@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('registration-password')),
      'Password@123',
    );
    await tester.enterText(
      find.byKey(const ValueKey('registration-confirm-password')),
      'Password@123',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('register-submit')));
    await tester.tap(find.byKey(const ValueKey('register-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('email already exists'), findsOneWidget);
    expect(find.text('Check your inbox'), findsNothing);
  });

  testWidgets('login stores a non-empty token and logout clears the session', (
    tester,
  ) async {
    final session = AuthSession();
    final client = _RecordingClient([
      http.Response('{"token":"signed.jwt.token"}', 200),
    ]);
    final api = _createAuthApi(client, session: session);
    addTearDown(api.close);
    await tester.pumpWidget(ShortLabApp(authApi: api));

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'ari@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'Password@123',
    );
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();

    expect(session.isAuthenticated, isTrue);
    expect(session.token, 'signed.jwt.token');
    expect(find.text('You are logged in'), findsOneWidget);
    expect(client.requests.single.url.path, '/api/auth/login');
    expect(client.requests.single.headers, isNot(contains('Authorization')));
    expect(jsonDecode(client.requests.single.body), {
      'email': 'ari@example.com',
      'password': 'Password@123',
    });

    await tester.tap(find.byKey(const ValueKey('logout')));
    await tester.pumpAndSettle();

    expect(session.isAuthenticated, isFalse);
    expect(session.token, isNull);
    expect(find.text('Make every link work smarter.'), findsOneWidget);
  });

  testWidgets('login rejects empty fields without calling the API', (
    tester,
  ) async {
    final client = _RecordingClient([]);
    final api = _createAuthApi(client);
    addTearDown(api.close);
    await tester.pumpWidget(ShortLabApp(authApi: api));

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('login-submit')));
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email address.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(client.requests, isEmpty);
  });

  testWidgets('login displays backend authentication errors', (tester) async {
    final client = _RecordingClient([
      http.Response('{"error":"email is not verified"}', 401),
    ]);
    final session = AuthSession();
    final api = _createAuthApi(client, session: session);
    addTearDown(api.close);
    await tester.pumpWidget(ShortLabApp(authApi: api));

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'ari@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'Password@123',
    );
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('email is not verified'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(session.isAuthenticated, isFalse);
  });

  testWidgets('login rejects a successful response without a token', (
    tester,
  ) async {
    final client = _RecordingClient([http.Response('{"message":"ok"}', 200)]);
    final session = AuthSession();
    final api = _createAuthApi(client, session: session);
    addTearDown(api.close);
    await tester.pumpWidget(ShortLabApp(authApi: api));

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'ari@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'Password@123',
    );
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();

    expect(
      find.text('The server did not return a valid login token.'),
      findsOneWidget,
    );
    expect(session.isAuthenticated, isFalse);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('landing page fits a narrow browser width', (tester) async {
    final api = _createAuthApi(_RecordingClient([]));
    addTearDown(api.close);
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(ShortLabApp(authApi: api));
    await tester.pumpAndSettle();

    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('async error state displays a retry action', (tester) async {
    var retryCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: AsyncStateView(
          isLoading: false,
          errorMessage: 'Could not load links.',
          onRetry: () => retryCount++,
          child: const Text('Loaded content'),
        ),
      ),
    );

    expect(find.text('Could not load links.'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retryCount, 1);
  });

  test('authenticated API requests add the Bearer token', () async {
    final session = AuthSession()..login('session.jwt.token');
    final client = _RecordingClient([http.Response('{"ok":true}', 200)]);
    final apiClient = ApiClient(
      client: client,
      baseUrl: 'http://localhost:8080',
      session: session,
    );
    addTearDown(apiClient.close);

    await apiClient.getJson(
      '/api/private',
      expectedStatus: 200,
      authenticated: true,
    );

    expect(
      client.requests.single.headers['Authorization'],
      'Bearer session.jwt.token',
    );
  });

  test('unauthorized authenticated response clears session safely', () async {
    final session = AuthSession()..login('session.jwt.token');
    final client = _RecordingClient([
      http.Response('{"error":"invalid or expired token"}', 401),
    ]);
    final apiClient = ApiClient(
      client: client,
      baseUrl: 'http://localhost:8080',
      session: session,
    );
    addTearDown(apiClient.close);

    await expectLater(
      apiClient.getJson(
        '/api/private',
        expectedStatus: 200,
        authenticated: true,
      ),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          'invalid or expired token',
        ),
      ),
    );

    expect(session.isAuthenticated, isFalse);
    expect(session.token, isNull);
  });

  test('malformed unauthorized response still clears session safely', () async {
    final session = AuthSession()..login('session.jwt.token');
    final client = _RecordingClient([http.Response('not json', 401)]);
    final apiClient = ApiClient(
      client: client,
      baseUrl: 'http://localhost:8080',
      session: session,
    );
    addTearDown(apiClient.close);

    await expectLater(
      apiClient.getJson(
        '/api/private',
        expectedStatus: 200,
        authenticated: true,
      ),
      throwsA(isA<ApiException>()),
    );
    expect(session.isAuthenticated, isFalse);
  });
}

AuthApi _createAuthApi(_RecordingClient client, {AuthSession? session}) {
  final activeSession = session ?? AuthSession();
  return AuthApi(
    client: ApiClient(
      client: client,
      baseUrl: 'http://localhost:8080',
      session: activeSession,
    ),
    session: activeSession,
  );
}

class _RecordedRequest {
  const _RecordedRequest(this.url, this.body, this.headers);

  final Uri url;
  final String body;
  final Map<String, String> headers;
}

class _RecordingClient extends http.BaseClient {
  _RecordingClient(this._responses);

  final List<http.Response> _responses;
  final requests = <_RecordedRequest>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = await request.finalize().bytesToString();
    requests.add(
      _RecordedRequest(request.url, body, Map.unmodifiable(request.headers)),
    );
    final response = _responses.removeAt(0);
    return http.StreamedResponse(
      Stream.value(utf8.encode(response.body)),
      response.statusCode,
      headers: response.headers,
    );
  }
}
