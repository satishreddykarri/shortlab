import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedLinkBackdrop extends StatefulWidget {
  const AnimatedLinkBackdrop({super.key});

  @override
  State<AnimatedLinkBackdrop> createState() => _AnimatedLinkBackdropState();
}

class _AnimatedLinkBackdropState extends State<AnimatedLinkBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _motion,
      builder:
          (context, _) => CustomPaint(
            painter: _LinkScenePainter(progress: _motion.value),
            size: Size.infinite,
          ),
    );
  }
}

class _LinkScenePainter extends CustomPainter {
  const _LinkScenePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFF3F5F1), BlendMode.srcOver);

    final horizon = size.height * 0.3;
    final gridPaint =
        Paint()
          ..color = const Color(0x123F7065)
          ..strokeWidth = 1;
    final vanishingPoint = Offset(size.width * 0.68, horizon);

    for (var index = 0; index <= 12; index++) {
      final x = size.width * index / 12;
      canvas.drawLine(vanishingPoint, Offset(x, size.height), gridPaint);
    }

    for (var index = 1; index <= 7; index++) {
      final depth = index / 7;
      final y = horizon + (size.height - horizon) * depth * depth;
      canvas.drawLine(
        Offset.zero.translate(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final movement = Curves.easeOutCubic.transform(progress);
    _drawLinkPanel(
      canvas,
      size,
      center: Offset(
        size.width * 0.86,
        size.height * (0.22 + movement * 0.025),
      ),
      width: math.min(size.width * 0.42, 250),
      height: 104,
      depth: 24,
      rotation: 0.52 - movement * 0.14,
      color: const Color(0xFFB77443),
    );
    _drawLinkPanel(
      canvas,
      size,
      center: Offset(
        size.width * 0.14,
        size.height * (0.73 - movement * 0.025),
      ),
      width: math.min(size.width * 0.46, 270),
      height: 116,
      depth: 28,
      rotation: -0.46 + movement * 0.12,
      color: const Color(0xFF32766A),
    );
  }

  void _drawLinkPanel(
    Canvas canvas,
    Size size, {
    required Offset center,
    required double width,
    required double height,
    required double depth,
    required double rotation,
    required Color color,
  }) {
    Offset project(double x, double y, double z) {
      final rotatedX = x * math.cos(rotation) - z * math.sin(rotation);
      final rotatedZ = x * math.sin(rotation) + z * math.cos(rotation);
      final scale = 760 / (760 + rotatedZ);
      return Offset(center.dx + rotatedX * scale, center.dy + y * scale);
    }

    final front = <Offset>[
      project(-width / 2, -height / 2, depth / 2),
      project(width / 2, -height / 2, depth / 2),
      project(width / 2, height / 2, depth / 2),
      project(-width / 2, height / 2, depth / 2),
    ];
    final back = <Offset>[
      project(-width / 2, -height / 2, -depth / 2),
      project(width / 2, -height / 2, -depth / 2),
      project(width / 2, height / 2, -depth / 2),
      project(-width / 2, height / 2, -depth / 2),
    ];

    final face = Path()..addPolygon(front, true);
    canvas.drawShadow(face, const Color(0x241E342E), 18, false);
    canvas.drawPath(
      face,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.76)
        ..style = PaintingStyle.fill,
    );

    final edgePaint =
        Paint()
          ..color = color.withValues(alpha: 0.42)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;
    canvas.drawPath(face, edgePaint);
    for (var index = 0; index < 4; index++) {
      canvas.drawLine(front[index], back[index], edgePaint);
      canvas.drawLine(back[index], back[(index + 1) % 4], edgePaint);
    }

    final left = project(-width * 0.32, -height * 0.12, depth / 2 + 0.5);
    final right = project(-width * 0.12, -height * 0.12, depth / 2 + 0.5);
    final nodePaint =
        Paint()
          ..color = color.withValues(alpha: 0.65)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
    canvas.drawCircle(left, 7, nodePaint);
    canvas.drawCircle(right, 7, nodePaint);
    canvas.drawLine(left.translate(5, 0), right.translate(-5, 0), nodePaint);

    final detailPaint =
        Paint()
          ..color = const Color(0xFF64736D).withValues(alpha: 0.2)
          ..strokeWidth = 2;
    for (var index = 0; index < 3; index++) {
      final y = height * (0.1 + index * 0.16);
      canvas.drawLine(
        project(width * 0.08, y, depth / 2 + 0.5),
        project(width * (index == 0 ? 0.36 : 0.28), y, depth / 2 + 0.5),
        detailPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LinkScenePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
