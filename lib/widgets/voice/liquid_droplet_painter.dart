import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class LiquidDropletPainter extends CustomPainter {
  final double animationValue; // 0.0 to 1.0 continuous phase
  final double amplitude; // 0.0 to 1.0 mic power
  final int rippleCount;

  LiquidDropletPainter({
    required this.animationValue,
    required this.amplitude,
    this.rippleCount = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) * 0.48;
    final baseRadius = 38.0 + (amplitude * 18.0);

    // 1. Draw Expanding Concentric Waves
    for (int i = 0; i < rippleCount; i++) {
      final wavePhase = (animationValue + (i / rippleCount)) % 1.0;
      final currentRadius = baseRadius + (maxRadius - baseRadius) * wavePhase;
      final waveOpacity = (1.0 - wavePhase) * 0.45 * (0.4 + amplitude * 0.6);

      final ripplePaint = Paint()
        ..color = AppColors.dropletRed.withValues(alpha: waveOpacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 + (1.0 - wavePhase) * 4.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

      // Subtle organic wave perturbation
      final path = Path();
      const segments = 60;
      for (int s = 0; s <= segments; s++) {
        final angle = (s / segments) * 2 * pi;
        final waveMod = sin(angle * 6 + animationValue * 4 * pi) * (2.0 * amplitude);
        final r = currentRadius + waveMod;
        final x = center.dx + r * cos(angle);
        final y = center.dy + r * sin(angle);
        if (s == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, ripplePaint);

      // Inner subtle glow fill
      final fillPaint = Paint()
        ..color = AppColors.dropletRedSoft.withValues(alpha: (waveOpacity * 0.18).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, currentRadius * 0.9, fillPaint);
    }

    // 2. Ambient Droplet Glow (Radial Gradient)
    final glowRadius = baseRadius * (1.8 + amplitude * 0.8);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.dropletRed.withValues(alpha: 0.65),
          AppColors.dropletRedSoft.withValues(alpha: 0.35),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: glowRadius));
    canvas.drawCircle(center, glowRadius, glowPaint);

    // 3. Core Liquid Droplet Shape with slight pulsing deformation
    final corePaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.3),
        colors: [
          Color(0xFFFF6484),
          AppColors.dropletRed,
          Color(0xFFBA002A),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius));

    final corePath = Path();
    const coreSegments = 40;
    for (int s = 0; s <= coreSegments; s++) {
      final angle = (s / coreSegments) * 2 * pi;
      // High-frequency subtle wobble
      final wobble = sin(angle * 4 + animationValue * 6 * pi) * (1.8 * amplitude);
      final r = baseRadius + wobble;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (s == 0) {
        corePath.moveTo(x, y);
      } else {
        corePath.lineTo(x, y);
      }
    }
    corePath.close();

    // Drop shadow under core droplet
    canvas.drawShadow(corePath, AppColors.dropletRed, 18, true);
    canvas.drawPath(corePath, corePaint);

    // 4. Specular Highlight for Glassy/Liquid feel
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    final highlightOffset = Offset(center.dx - baseRadius * 0.28, center.dy - baseRadius * 0.32);
    canvas.drawOval(
      Rect.fromCenter(center: highlightOffset, width: baseRadius * 0.45, height: baseRadius * 0.25),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant LiquidDropletPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.amplitude != amplitude;
  }
}
