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
              colors: [Color(0xFF1D2B27), Color(0xFF28584F), Color(0xFF34786B)],
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
          borderRadius: BorderRadius.circular(12),
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
                              ? const Color(0xFFB8C9C1)
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
                      color: isShort ? Colors.white : const Color(0xFF1D2B27),
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
                color: Color(0xFF8EA69C),
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
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0x5575A99A)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF9AD0B7), size: 13),
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
        ..color = const Color(0x779CC3B4)
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
                index == 0 ? const Color(0xFFC58A5C) : const Color(0x668EB7A9),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
