import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import '../landing/landing_page.dart';
import 'data/auth_api.dart';

class AuthenticatedPlaceholder extends StatelessWidget {
  const AuthenticatedPlaceholder({
    required this.authApi,
    required this.authSession,
    required this.email,
    super.key,
  });

  final AuthApi authApi;
  final AuthSession authSession;
  final String email;

  void _logout(BuildContext context) {
    authSession.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => LandingPage(authApi: authApi)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShortLab'),
        actions: [
          TextButton(
            key: const ValueKey('logout'),
            onPressed: () => _logout(context),
            child: const Text('Log out'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'You are logged in',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(email, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 12),
              Text(
                'Your ShortLab dashboard will be available here.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
