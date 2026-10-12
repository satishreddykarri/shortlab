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
                        SizedBox(height: isCompact ? 60 : 84),
                        const Divider(height: 1),
                        const SizedBox(height: 48),
                        const _InformationSection(),
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

class _InformationSection extends StatelessWidget {
  const _InformationSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;
        final capabilities = const [
          _Capability(
            number: '01',
            title: 'Choose your format',
            detail:
                'Use Base62, hash, random, UUID, or set a custom alias for a shortened URL.',
          ),
          _Capability(
            number: '02',
            title: 'Set an expiry',
            detail:
                'Choose an optional expiration date when a link should stop working.',
          ),
          _Capability(
            number: '03',
            title: 'Review activity',
            detail:
                'Open link analytics from your dashboard to see how your links are performing.',
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'More than a shorter URL',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: isCompact ? 30 : 38,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 660),
              child: Text(
                'ShortLab gives you control over how links are created, when they expire, and what happens after you share them.',
                style: theme.textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 34),
            if (isCompact)
              Column(
                children: [
                  for (var index = 0; index < capabilities.length; index++) ...[
                    _CapabilityItem(capability: capabilities[index]),
                    if (index < capabilities.length - 1) ...[
                      const SizedBox(height: 22),
                      const Divider(height: 1),
                      const SizedBox(height: 22),
                    ],
                  ],
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < capabilities.length; index++) ...[
                    Expanded(
                      child: _CapabilityItem(capability: capabilities[index]),
                    ),
                    if (index < capabilities.length - 1)
                      const SizedBox(width: 30),
                  ],
                ],
              ),
            const SizedBox(height: 58),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isCompact ? 20 : 30),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF1F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From destination to data',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A straightforward workflow, with the useful details close at hand.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 26),
                  if (isCompact)
                    const Column(
                      children: [
                        _WorkflowStep(
                          number: '1',
                          title: 'Add a destination',
                          detail: 'Paste the long URL you want to share.',
                        ),
                        SizedBox(height: 20),
                        _WorkflowStep(
                          number: '2',
                          title: 'Make it yours',
                          detail: 'Choose a format and optional expiry.',
                        ),
                        SizedBox(height: 20),
                        _WorkflowStep(
                          number: '3',
                          title: 'Share and review',
                          detail: 'Copy your link and check its analytics.',
                        ),
                      ],
                    )
                  else
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _WorkflowStep(
                            number: '1',
                            title: 'Add a destination',
                            detail: 'Paste the long URL you want to share.',
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: _WorkflowStep(
                            number: '2',
                            title: 'Make it yours',
                            detail: 'Choose a format and optional expiry.',
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: _WorkflowStep(
                            number: '3',
                            title: 'Share and review',
                            detail: 'Copy your link and check its analytics.',
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Capability {
  const _Capability({
    required this.number,
    required this.title,
    required this.detail,
  });

  final String number;
  final String title;
  final String detail;
}

class _CapabilityItem extends StatelessWidget {
  const _CapabilityItem({required this.capability});

  final _Capability capability;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          capability.number,
          style: theme.textTheme.labelLarge?.copyWith(
            color: const Color(0xFF2D7064),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          capability.title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: const Color(0xFF1D2B27),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(capability.detail, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _WorkflowStep extends StatelessWidget {
  const _WorkflowStep({
    required this.number,
    required this.title,
    required this.detail,
  });

  final String number;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: theme.textTheme.labelLarge?.copyWith(
              color: const Color(0xFF2D7064),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(detail, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
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
                color: const Color(0xFF2D7064),
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
                color: const Color(0xFF1D2B27),
                fontWeight: FontWeight.w700,
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
            color: const Color(0xFFE5EEE8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'LINKS, YOUR WAY',
            style: TextStyle(
              color: Color(0xFF2D7064),
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
