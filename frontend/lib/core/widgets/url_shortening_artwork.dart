import 'dart:math' as math;

import 'package:flutter/material.dart';

class UrlShorteningArtwork extends StatefulWidget {
  const UrlShorteningArtwork({super.key, this.height = 340});

  final double height;

  @override
  State<UrlShorteningArtwork> createState() => _UrlShorteningArtworkState();
}

class _UrlShorteningArtworkState extends State<UrlShorteningArtwork>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('url-shortening-artwork'),
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF111A3D), Color(0xFF252B68), Color(0xFF493FE0)],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 390;
              return AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final phase = _animation.value * math.pi * 2;
                  return Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Positioned(
                        top: -76,
                        right: -46,
                        child: _GlowOrb(
                          size: compact ? 180 : 240,
                          color: const Color(0x704E8BFF),
                        ),
                      ),
                      Positioned(
                        bottom: -105,
                        left: -68,
                        child: _GlowOrb(
                          size: compact ? 190 : 270,
                          color: const Color(0x6047D7C1),
                        ),
                      ),
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _OrbitPainter(progress: _animation.value),
                        ),
                      ),
                      Positioned(
                        top: compact ? 24 : 36,
                        left: compact ? 14 : 28,
                        child: Transform(
                          alignment: Alignment.center,
                          transform:
                              Matrix4.identity()
                                ..setEntry(3, 2, 0.0015)
                                ..rotateY(math.sin(phase) * 0.12)
                                ..rotateX(math.cos(phase) * 0.045)
                                ..rotateZ(-0.035),
                          child: _LinkPreviewCard(
                            compact: compact,
                            isShort: false,
                            float: math.sin(phase) * 5,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: compact ? 22 : 35,
                        right: compact ? 14 : 28,
                        child: Transform(
                          alignment: Alignment.center,
                          transform:
                              Matrix4.identity()
                                ..setEntry(3, 2, 0.0015)
                                ..rotateY(math.sin(phase + 1) * -0.1)
                                ..rotateX(math.cos(phase + 1) * 0.05)
                                ..rotateZ(0.035),
                          child: _LinkPreviewCard(
                            compact: compact,
                            isShort: true,
                            float: math.cos(phase) * 5,
                          ),
                        ),
                      ),
                      Positioned(
                        top: compact ? 16 : 24,
                        right: compact ? 16 : 28,
                        child: _FloatingBadge(
                          icon: Icons.bolt_rounded,
                          label: 'FAST',
                          offset: math.sin(phase + 2) * 5,
                        ),
                      ),
                      Positioned(
                        bottom: compact ? 18 : 28,
                        left: compact ? 18 : 34,
                        child: _FloatingBadge(
                          icon: Icons.auto_awesome_rounded,
                          label: 'YOUR RULES',
                          offset: math.cos(phase + 2) * 4,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LinkPreviewCard extends StatelessWidget {
  const _LinkPreviewCard({
    required this.compact,
    required this.isShort,
    required this.float,
  });

  final bool compact;
  final bool isShort;
  final double float;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 215.0 : 275.0;
    return Transform.translate(
      offset: Offset(0, float),
      child: Container(
        width: width,
        padding: EdgeInsets.all(compact ? 14 : 18),
        decoration: BoxDecoration(
          color: isShort ? const Color(0xF21D2851) : const Color(0xF8FFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isShort ? const Color(0x776A7AFF) : const Color(0xBFFFFFFF),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: compact ? 38 : 44,
              height: compact ? 38 : 44,
              decoration: BoxDecoration(
                color:
                    isShort ? const Color(0x334FE3CC) : const Color(0x1F5367F5),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                isShort ? Icons.link_rounded : Icons.public_rounded,
                color:
                    isShort ? const Color(0xFF69E6D0) : const Color(0xFF5367F5),
                size: compact ? 20 : 23,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isShort ? 'SHORT LINK' : 'YOUR DESTINATION',
                    style: TextStyle(
                      color:
                          isShort
                              ? const Color(0xFFB8C4EF)
                              : const Color(0xFF737D91),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isShort ? 'shortlab.io/aB29x' : 'example.com/long/article',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isShort ? Colors.white : const Color(0xFF18233B),
                      fontSize: compact ? 12 : 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (isShort)
              const Icon(
                Icons.content_copy_rounded,
                color: Color(0xFF8E9BCA),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  const _FloatingBadge({
    required this.icon,
    required this.label,
    required this.offset,
  });

  final IconData icon;
  final String label;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, offset),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xB52A376A),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0x447C8AFF)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF8DE8D9), size: 13),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final path =
        Path()
          ..moveTo(size.width * 0.2, size.height * 0.43)
          ..cubicTo(
            size.width * 0.5,
            size.height * 0.22,
            size.width * 0.43,
            size.height * 0.83,
            size.width * 0.79,
            size.height * 0.62,
          );
    final metric = path.computeMetrics().first;
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0x779DA9FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    for (var index = 0; index < 12; index++) {
      final distance = (index / 12 + progress) % 1 * metric.length;
      final point = metric.getTangentForOffset(distance)?.position;
      if (point != null) {
        canvas.drawCircle(
          point,
          index == 0 ? 3 : 1.4,
          Paint()
            ..color =
                index == 0 ? const Color(0xFF75F0D7) : const Color(0x668FA0FF),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
