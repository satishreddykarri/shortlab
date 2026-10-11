import 'package:flutter/material.dart';

import '../auth/data/auth_api.dart';
import '../auth/login_screen.dart';
import '../auth/registration_screen.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({required this.authApi, super.key});

  final AuthApi authApi;

  void _openRegistration(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RegistrationScreen(authApi: authApi),
      ),
    );
  }

  void _openLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => LoginScreen(authApi: authApi)),
    );
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
    return AspectRatio(
      aspectRatio: 1.12,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 390),
        decoration: BoxDecoration(
          color: const Color(0xFFEDF0FF),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 24,
              right: 30,
              child: _Dot(color: const Color(0xFF9DA8FF), size: 12),
            ),
            Positioned(
              bottom: 32,
              left: 34,
              child: _Dot(color: const Color(0xFFB3BDFB), size: 8),
            ),
            Container(
              width: 182,
              height: 182,
              decoration: BoxDecoration(
                color: const Color(0xFFDCE1FF),
                shape: BoxShape.circle,
              ),
            ),
            Transform.translate(
              offset: const Offset(-20, -27),
              child: const _LinkCard(
                icon: Icons.link_rounded,
                title: 'One link',
                subtitle: 'Your destination',
                color: Color(0xFF4658E8),
              ),
            ),
            Transform.translate(
              offset: const Offset(22, 62),
              child: const _LinkCard(
                icon: Icons.auto_awesome_rounded,
                title: 'Your style',
                subtitle: 'Your shortening rules',
                color: Color(0xFF168C73),
              ),
            ),
            Positioned(
              top: 58,
              left: 36,
              child: Icon(
                Icons.add_rounded,
                color: const Color(0xFF8D99F2),
                size: 23,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  const _LinkCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 224,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1718243B),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF18233B),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF737D91),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
