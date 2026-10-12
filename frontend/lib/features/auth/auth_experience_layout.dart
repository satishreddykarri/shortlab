import 'package:flutter/material.dart';

import '../../core/widgets/url_shortening_artwork.dart';

class AuthExperienceLayout extends StatelessWidget {
  const AuthExperienceLayout({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 24,
                ),
                child: Row(
                  children: [
                    const Expanded(flex: 11, child: _AuthHero()),
                    const SizedBox(width: 48),
                    Expanded(flex: 10, child: child),
                  ],
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                children: [
                  _BrandMark(size: 34),
                  const SizedBox(width: 10),
                  Text(
                    'ShortLab',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: SizedBox(
                height: constraints.maxHeight < 620 ? 118 : 168,
                child: const UrlShorteningArtwork(),
              ),
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

class _AuthHero extends StatelessWidget {
  const _AuthHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _BrandMark(size: 42),
            const SizedBox(width: 12),
            Text(
              'ShortLab',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 42),
        Text(
          'Long links in.\nSmart links out.',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontSize: 46,
            letterSpacing: -1.8,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Create, manage, and understand every link you share.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 30),
        const UrlShorteningArtwork(height: 300),
        const SizedBox(height: 20),
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _FeatureChip(icon: Icons.tune_rounded, label: 'Your rules'),
            _FeatureChip(icon: Icons.insights_rounded, label: 'Clear insights'),
          ],
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6174FF), Color(0xFF4658E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x334658E8),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Icon(Icons.link_rounded, color: Colors.white, size: size * 0.58),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF0FF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF4658E8), size: 16),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF303E8F),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
