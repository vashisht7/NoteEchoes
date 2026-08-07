import 'dart:math';
import 'package:flutter/material.dart';
import '../models/note_node.dart';
import '../theme/app_colors.dart';

class VoiceVisualizerPainter extends CustomPainter {
  final double animationValue; // 0.0 to 1.0 continuous animation phase
  final VoiceState state;
  final double amplitude; // 0.0 to 1.0 audio mic power

  VoiceVisualizerPainter({
    required this.animationValue,
    required this.state,
    this.amplitude = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final minDim = min(size.width, size.height);

    if (state == VoiceState.listening) {
      _paintLiquidWaterDropletRipples(canvas, center, minDim);
    } else if (state == VoiceState.thinking) {
      _paintDreamBubbleOrb(canvas, center, minDim);
    }
  }

  // ==========================================================
  // STATE 1: LISTENING - Water Dropping / Liquid Ripple Effect of Red Dot
  // ==========================================================
  void _paintLiquidWaterDropletRipples(Canvas canvas, Offset center, double minDim) {
    const rippleCount = 4;
    final maxRadius = minDim * 0.46;
    final baseRadius = 38.0 + (amplitude * 18.0);

    // 1. Expanding Concentric Waves
    for (int i = 0; i < rippleCount; i++) {
      final phase = (animationValue + (i / rippleCount)) % 1.0;
      final currentRadius = baseRadius + (maxRadius - baseRadius) * phase;
      final waveOpacity = (1.0 - phase) * 0.45 * (0.4 + amplitude * 0.6);

      final ripplePaint = Paint()
        ..color = AppColors.dropletRed.withValues(alpha: waveOpacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 + (1.0 - phase) * 3.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

      final path = Path();
      const segments = 60;
      for (int s = 0; s <= segments; s++) {
        final angle = (s / segments) * 2 * pi;
        final waveMod = sin(angle * 5 + animationValue * 4 * pi) * (1.8 * amplitude);
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

      // Subtle translucent water fill
      final fillPaint = Paint()
        ..color = AppColors.dropletRedSoft.withValues(alpha: (waveOpacity * 0.15).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, currentRadius * 0.92, fillPaint);
    }

    // 2. Ambient Red Core Glow
    final glowRadius = baseRadius * 1.6;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.dropletRed.withValues(alpha: 0.65),
          AppColors.dropletRedSoft.withValues(alpha: 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: glowRadius));
    canvas.drawCircle(center, glowRadius, glowPaint);

    // 3. Core Vivid Red Droplet
    final corePaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.3),
        colors: [
          Color(0xFFFF6484),
          AppColors.dropletRed,
          Color(0xFFBA002A),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius));

    canvas.drawCircle(center, baseRadius, corePaint);

    // 4. Specular Highlight for Liquid Droplet feel
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    final highlightOffset = Offset(center.dx - baseRadius * 0.28, center.dy - baseRadius * 0.32);
    canvas.drawOval(
      Rect.fromCenter(center: highlightOffset, width: baseRadius * 0.45, height: baseRadius * 0.25),
      highlightPaint,
    );
  }

  // ==========================================================
  // STATE 2: THINKING - Meta AI Dream Bubble Orb (#FF0844 glow & glass rim)
  // ==========================================================
  void _paintDreamBubbleOrb(Canvas canvas, Offset center, double minDim) {
    final bubbleRadius = minDim * 0.35;

    // 1. Outer Ambient Glow (#FF0844)
    final outerGlowRadius = bubbleRadius * 1.65;
    final outerGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF0844).withValues(alpha: 0.4),
          const Color(0x607D2AE8),
          const Color(0x3000F2FE),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: outerGlowRadius));
    canvas.drawCircle(center, outerGlowRadius, outerGlowPaint);

    // 2. Organic Wiggling Border Path using Trigonometric Noise
    final bubblePath = Path();
    const segments = 80;
    for (int i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * pi;
      final noise1 = sin(angle * 4 + animationValue * 2 * pi);
      final noise2 = cos(angle * 6 - animationValue * 3 * pi * 0.8);
      final offsetDist = (noise1 * 6.5) + (noise2 * 4.0);
      final r = bubbleRadius + offsetDist;

      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);

      if (i == 0) {
        bubblePath.moveTo(x, y);
      } else {
        bubblePath.lineTo(x, y);
      }
    }
    bubblePath.close();

    // 3. Translucent Orb Body Fill
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFF0844).withValues(alpha: 0.22),
          const Color(0xFF7D2AE8).withValues(alpha: 0.16),
          const Color(0xFF00F2FE).withValues(alpha: 0.12),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: bubbleRadius * 1.2))
      ..style = PaintingStyle.fill;
    canvas.drawPath(bubblePath, bodyPaint);

    // 4. Dream Bubble Wiggling Border Stroke
    final borderPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFF0844),
          Color(0xFFFF2D55),
          Color(0xFF00F2FE),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: bubbleRadius * 1.2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 1.2);
    canvas.drawPath(bubblePath, borderPaint);

    // 5. Specular Highlight Rim along the top edge
    final rimPath = Path();
    for (int i = 55; i <= 75; i++) {
      final angle = (i / segments) * 2 * pi;
      final noise1 = sin(angle * 4 + animationValue * 2 * pi);
      final r = bubbleRadius + (noise1 * 6.5) - 3.0;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 55) {
        rimPath.moveTo(x, y);
      } else {
        rimPath.lineTo(x, y);
      }
    }
    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawPath(rimPath, rimPaint);
  }

  @override
  bool shouldRepaint(covariant VoiceVisualizerPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.state != state ||
        oldDelegate.amplitude != amplitude;
  }
}
