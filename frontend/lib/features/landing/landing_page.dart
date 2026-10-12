import 'package:flutter/material.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/widgets/url_shortening_artwork.dart';
import '../auth/data/auth_api.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({required this.authApi, super.key});

  final AuthApi authApi;

  void _openRegistration(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.registration);
  }

  void _openLogin(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 760;
            final isNarrow = constraints.maxWidth < 390;

            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 22 : 48,
                      vertical: isCompact ? 20 : 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(
                          isNarrow: isNarrow,
                          onLogin: () => _openLogin(context),
                          onRegister: () => _openRegistration(context),
                        ),
                        SizedBox(height: isCompact ? 54 : 100),
                        if (isCompact)
                          _HeroCopy(
                            onGetStarted: () => _openRegistration(context),
                          )
                        else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 11,
                                child: _HeroCopy(
                                  onGetStarted:
                                      () => _openRegistration(context),
                                ),
                              ),
                              const SizedBox(width: 36),
                              const Expanded(
                                flex: 9,
                                child: _LinkIllustration(),
                              ),
                            ],
                          ),
                        if (isCompact) ...[
                          const SizedBox(height: 54),
                          const _LinkIllustration(),
                        ],
                        const SizedBox(height: 70),
                        const Divider(height: 1),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 24,
                          runSpacing: 14,
                          children: const [
                            _FeatureLabel(
                              icon: Icons.tune_rounded,
                              label: 'Flexible shortening methods',
                            ),
                            _FeatureLabel(
                              icon: Icons.schedule_rounded,
                              label: 'Optional link expiration',
                            ),
                            _FeatureLabel(
                              icon: Icons.insights_rounded,
                              label: 'Click analytics',
                            ),
                          ],
                        ),
                        const SizedBox(height: 36),
                        Text(
                          'A simple home for every link you share.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.isNarrow,
    required this.onLogin,
    required this.onRegister,
  });

  final bool isNarrow;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 12,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF4658E8),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.link_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 11),
            Text(
              'ShortLab',
              style: textTheme.titleLarge?.copyWith(
                color: const Color(0xFF18233B),
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: onLogin,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isNarrow ? 8 : 16,
                  vertical: 14,
                ),
              ),
              child: const Text('Log in'),
            ),
            const SizedBox(width: 4),
            FilledButton(
              onPressed: onRegister,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isNarrow ? 12 : 18,
                  vertical: 13,
                ),
              ),
              child: const Text('Register'),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.onGetStarted});

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 760;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF0FF),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            'LINKS, YOUR WAY',
            style: TextStyle(
              color: Color(0xFF4658E8),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Make every link work smarter.',
          style: (isCompact
                  ? textTheme.headlineMedium
                  : textTheme.headlineLarge)
              ?.copyWith(fontSize: isCompact ? 42 : 56),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            'A configurable URL-shortening platform for creating, '
            'managing, and understanding the links you share.',
            style: textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 30),
        FilledButton.icon(
          onPressed: onGetStarted,
          icon: const Icon(Icons.arrow_forward_rounded, size: 19),
          label: const Text('Get started'),
        ),
        const SizedBox(height: 12),
        Text(
          'Create an account to start shortening links.',
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _LinkIllustration extends StatelessWidget {
  const _LinkIllustration();

  @override
  Widget build(BuildContext context) {
    return const UrlShorteningArtwork(height: 390);
  }
}

class _FeatureLabel extends StatelessWidget {
  const _FeatureLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4658E8)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
