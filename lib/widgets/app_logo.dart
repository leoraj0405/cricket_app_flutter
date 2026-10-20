import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// CCCHub app mark: a green badge with three stumps, flying bails and a red
/// leather ball crashing into them. Drawn in code, so it is crisp at any size.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _LogoPainter()),
    );
  }
}

/// "CCC" + amber "Hub" wordmark.
class AppWordmark extends StatelessWidget {
  const AppWordmark({super.key, this.fontSize = 34, this.color = Colors.white});

  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.2,
      height: 1,
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'CCC',
            style: base.copyWith(color: color),
          ),
          TextSpan(
            text: 'Hub',
            style: base.copyWith(color: AppColors.amber),
          ),
        ],
      ),
      semanticsLabel: 'CCCHub',
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final rect = Offset.zero & size;

    // Badge: rounded square with an outfield gradient and an amber rim.
    final badge = RRect.fromRectAndRadius(rect, Radius.circular(s * 0.26));
    canvas.drawRRect(
      badge,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.pitchGreen, AppColors.darkGreen],
        ).createShader(rect),
    );
    canvas.drawRRect(
      badge.deflate(s * 0.03),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.02
        ..color = AppColors.amber.withValues(alpha: 0.85),
    );

    // Pitch strip behind the stumps.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.30, s * 0.70, s * 0.40, s * 0.08),
        Radius.circular(s * 0.04),
      ),
      Paint()..color = const Color(0xFFE8D9A8).withValues(alpha: 0.35),
    );

    // Stumps.
    final stumpPaint = Paint()..color = Colors.white;
    const stumpXs = [0.33, 0.465, 0.60];
    for (final x in stumpXs) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(s * x, s * 0.28, s * 0.07, s * 0.46),
          Radius.circular(s * 0.025),
        ),
        stumpPaint,
      );
    }

    // Bails, one knocked off and tilted.
    final bailPaint = Paint()..color = AppColors.amber;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.32, s * 0.235, s * 0.21, s * 0.045),
        Radius.circular(s * 0.02),
      ),
      bailPaint,
    );
    canvas.save();
    canvas.translate(s * 0.66, s * 0.17);
    canvas.rotate(-0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-s * 0.1, -s * 0.0225, s * 0.2, s * 0.045),
        Radius.circular(s * 0.02),
      ),
      bailPaint,
    );
    canvas.restore();

    // Cricket ball.
    final ballCenter = Offset(s * 0.67, s * 0.64);
    final ballRadius = s * 0.16;
    canvas.drawCircle(
      ballCenter.translate(s * 0.015, s * 0.02),
      ballRadius,
      Paint()..color = Colors.black.withValues(alpha: 0.25),
    );
    canvas.drawCircle(
      ballCenter,
      ballRadius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.4),
          colors: const [
            Color(0xFFFF6B5E),
            AppColors.ballRed,
            Color(0xFF8E1414),
          ],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: ballCenter, radius: ballRadius)),
    );

    // Seam: a curved line across the ball with stitch marks.
    canvas.save();
    canvas.translate(ballCenter.dx, ballCenter.dy);
    canvas.rotate(-math.pi / 4);
    final seamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.012
      ..strokeCap = StrokeCap.round;
    final seamRect = Rect.fromCenter(
      center: Offset.zero,
      width: ballRadius * 0.55,
      height: ballRadius * 2,
    );
    canvas.drawArc(seamRect, -math.pi / 2, math.pi, false, seamPaint);
    for (var i = 1; i < 6; i++) {
      final t = -math.pi / 2 + math.pi * i / 6;
      final p = Offset(
        seamRect.width / 2 * math.cos(t),
        seamRect.height / 2 * math.sin(t),
      );
      canvas.drawLine(
        p.translate(-s * 0.025, 0),
        p.translate(s * 0.025, 0),
        seamPaint..strokeWidth = s * 0.008,
      );
    }
    canvas.restore();

    // Highlight.
    canvas.drawCircle(
      ballCenter.translate(-ballRadius * 0.4, -ballRadius * 0.45),
      ballRadius * 0.18,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
