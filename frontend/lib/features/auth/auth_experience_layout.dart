import 'package:flutter/material.dart';

import '../../core/widgets/url_shortening_artwork.dart';

class AuthExperienceLayout extends StatelessWidget {
  const AuthExperienceLayout({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= 980) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(flex: 7, child: _AuthHero()),
                        const SizedBox(width: 28),
                        Expanded(flex: 5, child: child),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        if (width >= 640) {
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        const _BrandRow(size: 36),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 180,
                          child: const UrlShorteningArtwork(),
                        ),
                        const SizedBox(height: 18),
                        child,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 4),
                      const _BrandRow(size: 30),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 140,
                        child: const UrlShorteningArtwork(),
                      ),
                      const SizedBox(height: 16),
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BrandMark(size: size),
        const SizedBox(width: 10),
        Text(
          'ShortLab',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
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
          'A better handle\non every link.',
          style: theme.textTheme.headlineLarge?.copyWith(fontSize: 44),
        ),
        const SizedBox(height: 14),
        Text(
          'Choose how links are made, share them cleanly, and review click activity in one workspace.',
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
        color: const Color(0xFF2D7064),
        borderRadius: BorderRadius.circular(size * 0.24),
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
        color: const Color(0xFFE5EEE8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF2D7064), size: 16),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF31574F),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
