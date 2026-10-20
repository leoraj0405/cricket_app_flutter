import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Night-stadium backdrop: navy gradient with faint cricket-ground markings
/// (boundary, 30-yard circle and the pitch).
class GroundBackground extends StatelessWidget {
  const GroundBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.navy, AppColors.navyLight, AppColors.darkGreen],
          stops: [0, 0.55, 1],
        ),
      ),
      child: CustomPaint(painter: _GroundPainter(), child: child),
    );
  }
}

class _GroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.22);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.06);

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 1.5,
        height: size.width * 1.1,
      ),
      line,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.95,
        height: size.width * 0.7,
      ),
      line,
    );
    canvas.drawRect(
      Rect.fromCenter(center: center, width: 26, height: size.width * 0.32),
      line,
    );

    // Floodlight glow from the top corners.
    for (final dx in [0.0, size.width]) {
      canvas.drawCircle(
        Offset(dx, 0),
        size.width * 0.45,
        Paint()
          ..shader =
              RadialGradient(
                colors: [
                  AppColors.amber.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ).createShader(
                Rect.fromCircle(
                  center: Offset(dx, 0),
                  radius: size.width * 0.45,
                ),
              ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
