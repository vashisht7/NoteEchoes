import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class NebulaLiquidPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0 continuous fluid phase
  final double scale; // Dynamic scale for breathing
  final double intensity;

  NebulaLiquidPainter({
    required this.progress,
    this.scale = 1.0,
    this.intensity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = min(size.width, size.height) * 0.28 * scale;

    // 1. Ambient Background Nebula Glow
    final ambientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.nebulaViolet.withValues(alpha: 0.45 * intensity),
          AppColors.nebulaCyan.withValues(alpha: 0.30 * intensity),
          AppColors.nebulaMagenta.withValues(alpha: 0.25 * intensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius * 2.2));
    canvas.drawCircle(center, baseRadius * 2.2, ambientPaint);

    // 2. Multi-blob Liquid Morphing (Layer 1: Violet/Indigo)
    _drawBlob(
      canvas: canvas,
      center:
          center +
          Offset(sin(progress * 2 * pi) * 14, cos(progress * 2 * pi) * 12),
      radius: baseRadius * 1.05,
      color: AppColors.nebulaViolet,
      secondaryColor: AppColors.nebulaIndigo,
      phaseOffset: 0.0,
      complexity: 6,
      wobblePower: 22.0,
    );

    // 3. Multi-blob Liquid Morphing (Layer 2: Cyan/Teal Swirl)
    _drawBlob(
      canvas: canvas,
      center:
          center +
          Offset(
            cos(progress * 2 * pi * 1.3) * -16,
            sin(progress * 2 * pi * 1.3) * 14,
          ),
      radius: baseRadius * 0.92,
      color: AppColors.nebulaCyan,
      secondaryColor: const Color(0xFF0072FF),
      phaseOffset: pi / 2,
      complexity: 7,
      wobblePower: 26.0,
      opacity: 0.85,
    );

    // 4. Multi-blob Liquid Morphing (Layer 3: Vivid Pink/Magenta Core)
    _drawBlob(
      canvas: canvas,
      center:
          center +
          Offset(
            sin(progress * 2 * pi * 0.9) * 10,
            -cos(progress * 2 * pi * 0.9) * 12,
          ),
      radius: baseRadius * 0.78,
      color: AppColors.nebulaMagenta,
      secondaryColor: const Color(0xFFD7192D),
      phaseOffset: pi,
      complexity: 5,
      wobblePower: 18.0,
      opacity: 0.88,
    );

    // 5. Luminescent Swirling Core Center
    final coreGlow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.95),
              AppColors.nebulaCyan.withValues(alpha: 0.6),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 1.0],
          ).createShader(
            Rect.fromCircle(center: center, radius: baseRadius * 0.45),
          );
    canvas.drawCircle(center, baseRadius * 0.45, coreGlow);

    // 6. Floating Energy Sparkles/Stars
    final sparklePaint = Paint()..color = Colors.white;
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * pi + (progress * 2 * pi * 0.4);
      final dist = baseRadius * (0.8 + 0.35 * sin(progress * 4 * pi + i));
      final pX = center.dx + dist * cos(angle);
      final pY = center.dy + dist * sin(angle);
      final starSize = 1.8 + 1.2 * sin(progress * 6 * pi + i * 2).abs();
      canvas.drawCircle(
        Offset(pX, pY),
        starSize,
        sparklePaint..color = Colors.white.withValues(alpha: 0.85),
      );
    }
  }

  void _drawBlob({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required Color color,
    required Color secondaryColor,
    required double phaseOffset,
    required int complexity,
    required double wobblePower,
    double opacity = 0.75,
  }) {
    final path = Path();
    const segments = 90;

    for (int i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * pi;
      // Multi-harmonic fluid wiggling physics
      final harmonic1 = sin(
        angle * complexity + (progress * 2 * pi) + phaseOffset,
      );
      final harmonic2 = cos(
        angle * (complexity - 2) - (progress * 2 * pi * 1.5) + phaseOffset,
      );
      final r = radius + (harmonic1 * 0.6 + harmonic2 * 0.4) * wobblePower;

      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final blobPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: opacity),
          secondaryColor.withValues(alpha: opacity * 0.85),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.2))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);

    canvas.drawPath(path, blobPaint);
  }

  @override
  bool shouldRepaint(covariant NebulaLiquidPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.scale != scale ||
        oldDelegate.intensity != intensity;
  }
}
