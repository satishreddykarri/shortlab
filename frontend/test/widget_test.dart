import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shortlab/app.dart';
import 'package:shortlab/core/auth/auth_session.dart';
import 'package:shortlab/core/config/api_config.dart';
import 'package:shortlab/core/network/api_client.dart';
import 'package:shortlab/core/widgets/async_state_view.dart';
import 'package:shortlab/features/auth/data/auth_api.dart';
import 'package:shortlab/features/urls/data/url_api.dart';

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

  testWidgets('registration uses responsive URL-shortening artwork', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final api = _createAuthApi(_RecordingClient([]));
    addTearDown(api.close);
    await tester.pumpWidget(ShortLabApp(authApi: api));
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('url-shortening-artwork')),
      findsOneWidget,
    );
    expect(find.text('Long links in.\nSmart links out.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('url-shortening-artwork')),
      findsOneWidget,
    );
    expect(find.text('Long links in.\nSmart links out.'), findsNothing);
    expect(tester.takeException(), isNull);
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
    await tester.ensureVisible(find.byKey(const ValueKey('verify-submit')));
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
      http.Response('{"urls":[]}', 200),
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
    await tester.ensureVisible(find.byKey(const ValueKey('login-submit')));
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();

    expect(session.isAuthenticated, isTrue);
    expect(session.token, 'signed.jwt.token');
    expect(find.text('Dashboard'), findsOneWidget);
    expect(client.requests[0].url.path, '/api/auth/login');
    expect(client.requests[0].headers, isNot(contains('Authorization')));
    expect(jsonDecode(client.requests[0].body), {
      'email': 'ari@example.com',
      'password': 'Password@123',
    });
    expect(client.requests[1].url.path, '/api/urls');

    await tester.tap(find.byKey(const ValueKey('dashboard-logout')));
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
    await tester.ensureVisible(find.byKey(const ValueKey('login-submit')));
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
    await tester.ensureVisible(find.byKey(const ValueKey('login-submit')));
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
    await tester.ensureVisible(find.text('Try again'));
    await tester.tap(find.text('Try again'));
    expect(retryCount, 1);
  });

  testWidgets('dashboard creates a URL with selected algorithm and refreshes', (
    tester,
  ) async {
    final createdUrl = _urlResponse(shortCode: 'r4nd0m', algorithm: 'random');
    final client = _RecordingClient([
      http.Response('{"token":"jwt.token"}', 200),
      http.Response('{"urls":[]}', 200),
      http.Response(
        jsonEncode({
          'message': 'short URL created successfully',
          'url': createdUrl,
        }),
        201,
      ),
      http.Response(
        jsonEncode({
          'urls': [createdUrl],
        }),
        200,
      ),
    ]);
    final api = _createAuthApi(client);
    addTearDown(api.close);
    await tester.pumpWidget(ShortLabApp(authApi: api));
    await _login(tester);

    expect(
      find.text('No shortened links yet. Create your first one above.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('algorithm-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Random').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('original-url')),
      'https://example.com/article',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('create-url-submit')));
    await tester.tap(find.byKey(const ValueKey('create-url-submit')));
    await tester.pumpAndSettle();

    expect(client.requests, hasLength(4));
    final createRequest = client.requests[2];
    expect(createRequest.method, 'POST');
    expect(createRequest.url.path, '/api/urls');
    expect(createRequest.headers['Authorization'], 'Bearer jwt.token');
    expect(jsonDecode(createRequest.body), {
      'original_url': 'https://example.com/article',
      'algorithm': 'random',
    });
    expect(find.text('Short link created'), findsOneWidget);
    expect(find.byKey(const ValueKey('created-short-url')), findsOneWidget);
    expect(
      tester
          .widget<SelectableText>(
            find.byKey(const ValueKey('created-short-url')),
          )
          .data,
      '${ApiConfig.baseUrl}/r4nd0m',
    );
    expect(find.text('Method: Random'), findsOneWidget);
    expect(client.requests[3].url.path, '/api/urls');
  });

  testWidgets('custom alias is conditional and validated before request', (
    tester,
  ) async {
    final client = _RecordingClient([
      http.Response('{"token":"jwt.token"}', 200),
      http.Response('{"urls":[]}', 200),
    ]);
    final api = _createAuthApi(client);
    addTearDown(api.close);
    await tester.pumpWidget(ShortLabApp(authApi: api));
    await _login(tester);

    expect(find.byKey(const ValueKey('custom-alias')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('algorithm-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom alias').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('custom-alias')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('original-url')),
      'https://example.com',
    );
    await tester.enterText(find.byKey(const ValueKey('custom-alias')), 'x!');
    await tester.ensureVisible(find.byKey(const ValueKey('create-url-submit')));
    await tester.tap(find.byKey(const ValueKey('create-url-submit')));
    await tester.pumpAndSettle();

    expect(
      find.text('Custom alias must be at least 3 characters.'),
      findsOneWidget,
    );
    await tester.enterText(find.byKey(const ValueKey('custom-alias')), 'ab!');
    await tester.ensureVisible(find.byKey(const ValueKey('create-url-submit')));
    await tester.tap(find.byKey(const ValueKey('create-url-submit')));
    await tester.pumpAndSettle();

    expect(
      find.text('Use only letters, numbers, hyphens, and underscores.'),
      findsOneWidget,
    );
    expect(client.requests, hasLength(2));
  });

  testWidgets('dashboard reports create and list errors without fake success', (
    tester,
  ) async {
    final client = _RecordingClient([
      http.Response('{"token":"jwt.token"}', 200),
      http.Response('{"urls":[]}', 200),
      http.Response('{"error":"short code already exists"}', 409),
    ]);
    final api = _createAuthApi(client);
    addTearDown(api.close);
    await tester.pumpWidget(ShortLabApp(authApi: api));
    await _login(tester);

    await tester.enterText(
      find.byKey(const ValueKey('original-url')),
      'https://example.com',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('create-url-submit')));
    await tester.tap(find.byKey(const ValueKey('create-url-submit')));
    await tester.pumpAndSettle();

    expect(find.text('short code already exists'), findsOneWidget);
    expect(find.byKey(const ValueKey('created-url-result')), findsNothing);

    final listClient = _RecordingClient([
      http.Response('{"token":"jwt.token"}', 200),
      http.Response('{"error":"service unavailable"}', 500),
      http.Response('{"urls":[]}', 200),
    ]);
    final listApi = _createAuthApi(listClient);
    addTearDown(listApi.close);
    await tester.pumpWidget(
      ShortLabApp(key: const ValueKey('list-error-app'), authApi: listApi),
    );
    await _login(tester);

    expect(find.text('service unavailable'), findsOneWidget);
    await tester.ensureVisible(find.text('Try again'));
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(
      find.text('No shortened links yet. Create your first one above.'),
      findsOneWidget,
    );
    expect(listClient.requests[2].url.path, '/api/urls');
  });

  testWidgets('copy action puts configured short URL on clipboard', (
    tester,
  ) async {
    final client = _RecordingClient([
      http.Response('{"token":"jwt.token"}', 200),
      http.Response(
        jsonEncode({
          'urls': [_urlResponse(shortCode: 'abc123')],
        }),
        200,
      ),
    ]);
    final api = _createAuthApi(client);
    addTearDown(api.close);
    String? copiedText;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copiedText = (call.arguments as Map)['text'] as String?;
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await tester.pumpWidget(ShortLabApp(authApi: api));
    await _login(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('copy-short-url-1')));
    await tester.tap(find.byKey(const ValueKey('copy-short-url-1')));
    await tester.pumpAndSettle();

    expect(copiedText, '${ApiConfig.baseUrl}/abc123');
    expect(find.text('Short URL copied to clipboard.'), findsOneWidget);
  });

  testWidgets('deletion requires confirmation and removes the link', (
    tester,
  ) async {
    final url = _urlResponse(shortCode: 'delete-me');
    final client = _RecordingClient([
      http.Response('{"token":"jwt.token"}', 200),
      http.Response(
        jsonEncode({
          'urls': [url],
        }),
        200,
      ),
      http.Response('{"message":"URL deleted successfully"}', 200),
    ]);
    final api = _createAuthApi(client);
    addTearDown(api.close);
    await tester.pumpWidget(ShortLabApp(authApi: api));
    await _login(tester);

    await tester.ensureVisible(find.byKey(const ValueKey('delete-url-1')));
    await tester.tap(find.byKey(const ValueKey('delete-url-1')));
    await tester.pumpAndSettle();
    expect(client.requests, hasLength(2));

    await tester.tap(find.byKey(const ValueKey('confirm-delete-url')));
    await tester.pumpAndSettle();

    expect(client.requests, hasLength(3));
    expect(client.requests.last.method, 'DELETE');
    expect(client.requests.last.url.path, '/api/urls/1');
    expect(
      client.requests.last.headers['Authorization']!.startsWith('Bearer '),
      isTrue,
    );
    expect(find.text('Short link deleted.'), findsOneWidget);
    expect(find.byKey(const ValueKey('short-url-1')), findsNothing);
  });

  testWidgets('cancelled deletion does not call the delete endpoint', (
    tester,
  ) async {
    final client = _RecordingClient([
      http.Response('{"token":"jwt.token"}', 200),
      http.Response(
        jsonEncode({
          'urls': [_urlResponse()],
        }),
        200,
      ),
    ]);
    final api = _createAuthApi(client);
    addTearDown(api.close);
    await tester.pumpWidget(ShortLabApp(authApi: api));
    await _login(tester);

    await tester.ensureVisible(find.byKey(const ValueKey('delete-url-1')));
    await tester.tap(find.byKey(const ValueKey('delete-url-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cancel-delete-url')));
    await tester.pumpAndSettle();

    expect(client.requests, hasLength(2));
    expect(find.byKey(const ValueKey('short-url-1')), findsOneWidget);
  });

  testWidgets('deletion failure keeps the URL visible', (tester) async {
    final client = _RecordingClient([
      http.Response('{"token":"jwt.token"}', 200),
      http.Response(
        jsonEncode({
          'urls': [_urlResponse()],
        }),
        200,
      ),
      http.Response('{"error":"failed to delete URL"}', 500),
    ]);
    final api = _createAuthApi(client);
    addTearDown(api.close);
    await tester.pumpWidget(ShortLabApp(authApi: api));
    await _login(tester);

    await tester.ensureVisible(find.byKey(const ValueKey('delete-url-1')));
    await tester.tap(find.byKey(const ValueKey('delete-url-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-delete-url')));
    await tester.pumpAndSettle();

    expect(find.text('failed to delete URL'), findsOneWidget);
    expect(find.byKey(const ValueKey('short-url-1')), findsOneWidget);
  });

  testWidgets('analytics displays URL metadata and click details', (
    tester,
  ) async {
    final analytics = _analyticsResponse();
    final refreshedAnalytics = _analyticsResponse()..['total_clicks'] = 18;
    final client = _RecordingClient([
      http.Response('{"token":"jwt.token"}', 200),
      http.Response(
        jsonEncode({
          'urls': [_urlResponse()],
        }),
        200,
      ),
      http.Response(jsonEncode({'analytics': analytics}), 200),
      http.Response(jsonEncode({'analytics': refreshedAnalytics}), 200),
    ]);
    final api = _createAuthApi(client);
    addTearDown(api.close);
    await tester.pumpWidget(ShortLabApp(authApi: api));
    await _login(tester);

    await tester.ensureVisible(find.byKey(const ValueKey('analytics-url-1')));
    await tester.tap(find.byKey(const ValueKey('analytics-url-1')));
    await tester.pumpAndSettle();

    expect(client.requests.last.url.path, '/api/urls/1/analytics');
    expect(
      client.requests.last.headers['Authorization']!.startsWith('Bearer '),
      isTrue,
    );
    expect(find.text('Link analytics'), findsOneWidget);
    expect(find.text('17 total'), findsOneWidget);
    expect(find.text('IP address: 203.0.113.8'), findsOneWidget);
    expect(find.text('User agent: ShortLab test browser'), findsOneWidget);
    expect(find.text('Referrer: https://news.example/'), findsOneWidget);
    expect(find.text('Short code: abc123'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('analytics-url-1')));
    await tester.pumpAndSettle();
    expect(find.text('18 total'), findsOneWidget);
    expect(
      client.requests.where(
        (request) => request.url.path == '/api/urls/1/analytics',
      ),
      hasLength(2),
    );
  });

  testWidgets('analytics with zero clicks has an explicit empty state', (
    tester,
  ) async {
    final analytics =
        _analyticsResponse()
          ..['total_clicks'] = 0
          ..['clicks'] = [];
    final client = _RecordingClient([
      http.Response('{"token":"jwt.token"}', 200),
      http.Response(
        jsonEncode({
          'urls': [_urlResponse()],
        }),
        200,
      ),
      http.Response(jsonEncode({'analytics': analytics}), 200),
    ]);
    final api = _createAuthApi(client);
    addTearDown(api.close);
    await tester.pumpWidget(ShortLabApp(authApi: api));
    await _login(tester);

    await tester.ensureVisible(find.byKey(const ValueKey('analytics-url-1')));
    await tester.tap(find.byKey(const ValueKey('analytics-url-1')));
    await tester.pumpAndSettle();

    expect(find.text('0 total'), findsOneWidget);
    expect(find.text('No clicks recorded yet.'), findsOneWidget);
  });

  testWidgets('analytics request failure shows an error and retry', (
    tester,
  ) async {
    final client = _RecordingClient([
      http.Response('{"token":"jwt.token"}', 200),
      http.Response(
        jsonEncode({
          'urls': [_urlResponse()],
        }),
        200,
      ),
      http.Response('{"error":"failed to fetch analytics"}', 500),
      http.Response(jsonEncode({'analytics': _analyticsResponse()}), 200),
    ]);
    final api = _createAuthApi(client);
    addTearDown(api.close);
    await tester.pumpWidget(ShortLabApp(authApi: api));
    await _login(tester);

    await tester.ensureVisible(find.byKey(const ValueKey('analytics-url-1')));
    await tester.tap(find.byKey(const ValueKey('analytics-url-1')));
    await tester.pumpAndSettle();
    expect(find.text('failed to fetch analytics'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('retry-analytics')));
    await tester.pumpAndSettle();
    expect(find.text('17 total'), findsOneWidget);
    expect(client.requests.last.url.path, '/api/urls/1/analytics');
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

  test('custom URL request includes alias and UTC expiration fields', () async {
    final session = AuthSession()..login('jwt.token');
    final responseUrl = _urlResponse(shortCode: 'my-link', algorithm: 'custom')
      ..['expires_at'] = '2030-01-02T03:04:00Z';
    final client = _RecordingClient([
      http.Response(
        jsonEncode({'message': 'created', 'url': responseUrl}),
        201,
      ),
    ]);
    final apiClient = ApiClient(
      client: client,
      baseUrl: 'http://localhost:8080',
      session: session,
    );
    addTearDown(apiClient.close);
    final urlApi = UrlApi(apiClient);

    await urlApi.create(
      originalUrl: 'https://example.com',
      algorithm: 'custom',
      customAlias: 'my-link',
      expiresAt: DateTime.utc(2030, 1, 2, 3, 4),
    );

    expect(jsonDecode(client.requests.single.body), {
      'original_url': 'https://example.com',
      'algorithm': 'custom',
      'custom_alias': 'my-link',
      'expires_at': '2030-01-02T03:04:00.000Z',
    });
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

Future<void> _login(WidgetTester tester) async {
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
  await tester.ensureVisible(find.byKey(const ValueKey('login-submit')));
  await tester.tap(find.byKey(const ValueKey('login-submit')));
  await tester.pumpAndSettle();
}

Map<String, Object?> _urlResponse({
  String shortCode = 'abc123',
  String algorithm = 'base62',
}) {
  return {
    'id': 1,
    'original_url': 'https://example.com/article',
    'short_code': shortCode,
    'algorithm': algorithm,
    'expires_at': null,
    'created_at': '2026-10-11T12:00:00Z',
  };
}

Map<String, Object?> _analyticsResponse() {
  return {
    'url_id': 1,
    'original_url': 'https://example.com/article',
    'short_code': 'abc123',
    'algorithm': 'base62',
    'created_at': '2026-10-11T12:00:00Z',
    'expires_at': null,
    'total_clicks': 17,
    'clicks': [
      {
        'id': 91,
        'clicked_at': '2026-10-11T12:30:00Z',
        'ip_address': '203.0.113.8',
        'user_agent': 'ShortLab test browser',
        'referrer': 'https://news.example/',
      },
    ],
  };
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
  const _RecordedRequest(this.method, this.url, this.body, this.headers);

  final String method;
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
      _RecordedRequest(
        request.method,
        request.url,
        body,
        Map.unmodifiable(request.headers),
      ),
    );
    final response = _responses.removeAt(0);
    return http.StreamedResponse(
      Stream.value(utf8.encode(response.body)),
      response.statusCode,
      headers: response.headers,
    );
  }
}
